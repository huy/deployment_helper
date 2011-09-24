require 'fileutils'
include FileUtils

require File.dirname(__FILE__) + '/utils'
require File.dirname(__FILE__) + '/env_config'

class DeploymentManager
  attr_accessor :target,:app_code,:release_number,:timestamp,:dry_mode,:items

  def initialize(params)
    # for deployment statistic purposes
    @deployment_report = {}
    @deployment_report[:deployed_files] = {}
    @deployment_report[:patched_jars] = {}

    @release_number = params[:release_number]
    @app_code = params[:app_code].to_sym
    @target = params[:target]
    @timestamp = Time.now.strftime('%Y-%m-%d_%H.%M.%S')

    @dry_mode= if ARGV[0].nil? 
       true
    else
       ARGV[0] == '--force' or ARGV[0] == '--true' or ARGV[0] == '-f' 
    end 
    puts "--- DRY=#{dry_mode}"
  end

  def release_dir
    "#{release_root[@app_code]}/#{@release_number}"
  end

  def pre_release
    "#{stage_dir}/rollback/#{@target}/pre-release"
  end

  def post_release
    "#{stage_dir}/rollback/#{@target}/post-release"
  end

  def stage_dir
    "#{stage_root}/#{@release_number}/#{@timestamp}"  
  end

  def logfile
      "#{stage_dir}/rollback/#{target}/#{release_number}_app_to_#{target}_on_#{timestamp}.log"
  end

  def deploy_component_files(params)

    params[:release_dir] ||= release_dir
    params[:pre_release] ||= pre_release
    params[:dry] ||= dry_mode
    params[:items] = params[:items].to_a
    subsystem = params[:subsystem] || params[:tier]
    component = params[:component] 

    each_site do |site|
      @deployment_report[:deployed_files][subsystem] ||= {} 
      @deployment_report[:deployed_files][subsystem][component] ||= {} 
      @deployment_report[:deployed_files][subsystem][component][site] ||= {} 

      utl_subsystem_hosts(site,subsystem,params[:instance]).each do |host|
        @deployment_report[:deployed_files][subsystem][component][site][host.host] ||= [] 
        params[:remote_machine] = host
        params[:runtime_area] = utl_component_dir(site,subsystem,component,params[:instance])
        @deployment_report[:deployed_files][subsystem][component][site][host.host].concat(utl_deploy_files(params))
      end      
    end

  end

  def deploy_component_jars(params)
    params[:release_dir] ||= release_dir
    params[:pre_release] ||= pre_release
    params[:dry] ||= dry_mode

    subsystem = params[:tier] || params[:subsystem]
    items = params[:items].to_a

    component = params[:component]

    each_site do |site|
      @deployment_report[:deployed_files][subsystem] ||= {} 
      @deployment_report[:deployed_files][subsystem][component] ||= {} 
      @deployment_report[:deployed_files][subsystem][component][site] ||= {}
      post_release_site = "#{post_release}/#{subsystem}/#{component}/#{site}"
  
      seed_machine = utl_subsystem_hosts(site,subsystem,params[:instance]).first
      seed_runtime_area = utl_component_dir(site,subsystem,component,params[:instance])
      patch_jars(seed_machine,seed_runtime_area,items,subsystem,component,site)

      utl_subsystem_hosts(site, subsystem,params[:instance]).each do |host|
            @deployment_report[:deployed_files][subsystem][component][site][host.host] ||= []

            @deployment_report[:deployed_files][subsystem][component][site][host.host].concat( 
             utl_deploy_jars(:pre_release=>pre_release,
               :post_release=>post_release_site,
               :remote_machine=>host,
               :runtime_area=>utl_component_dir(site,subsystem,component,params[:instance]),
               :items=>items,
               :dry=>dry_mode))
      end  

    end
  end

  def copy_dir_in_runtime(params)
    subsystem = params[:subsystem] || params[:tier]
    src = params[:src]
    dest = params[:dest]

    each_site do |site|      
      utl_subsystem_hosts(site,subsystem,params[:instance]).each do |host|
        host.copy_in_location(:location=>utl_component_dir(site,subsystem,:runtime,params[:instance]), 
                              :src=>src, 
                              :dest=>dest, 
                              :dry=>dry_mode)
      end      
    end 
  end

  def run(&block)
    mkdir_p pre_release
    mkdir_p post_release   

    rm_rf logfile

    log_output(logfile,"w") do 
      instance_eval &block 
      @endtime =  Time.now.strftime('%Y-%m-%d_%H.%M.%S')
      print_summary # will go to log file
    end
    print_summary # will go to screen
  end

private

  def print_summary
    puts "*************************************************************\n"
    puts "** Deployment Summary:\n"
    puts "*************************************************************\n"    

    puts "\nStart time: #{@timestamp}\n"
    puts "End time: #{@endtime}\n"
    puts "\n\n** Patched jar files:\n"  
     @deployment_report[:patched_jars].keys.each do |tier|
      puts "\n"
      puts "+ Subsystem: #{tier}\n"  
      
      @deployment_report[:patched_jars][tier].keys.each do |component|
        puts "| \n"
        puts "|-+ Component: #{component}\n"  


        @deployment_report[:patched_jars][tier][component].keys.each do |site|
          puts "| | \n"
          puts "| |-+ Site: #{site}\n"  
           @deployment_report[:patched_jars][tier][component][site].keys.each do |item|
              puts "| | |  \n"
              puts "| | | |-+ Jar: #{item}"
              puts "| | | | |  copied from host: #{@deployment_report[:patched_jars][tier][component][site][item][:seed_machine]}"
              puts "| | | | |  copied to local staging area:: #{@deployment_report[:patched_jars][tier][component][site][item][:dest]}"          
              puts "| | | | |  patched with class files from: #{@deployment_report[:patched_jars][tier][component][site][item][:src]}"
               
              puts "| | | | |-+  class files patched: #{@deployment_report[:patched_jars][tier][component][site][item][:patched_classes].size}"
              @deployment_report[:patched_jars][tier][component][site][item][:patched_classes].each do |clazz|
                puts "| | | | | |-+  #{clazz[:classname]}"
              end

             
          end
        end
      end
    end


   puts "\n\n** Deployed files:\n"  
      @deployment_report[:deployed_files].keys.each do |tier|
      puts "\n"
      puts "+ Subsystem: #{tier}\n"  
      
      @deployment_report[:deployed_files][tier].keys.each do |component|
        puts "| \n"
        puts "|-+ Component: #{component}\n"  


        @deployment_report[:deployed_files][tier][component].keys.each do |site|
          puts "| | \n"
          puts "| |-+ Site: #{site}\n"  

          @deployment_report[:deployed_files][tier][component][site].keys.each do |host|
            puts "| | | \n"
            puts "| | |-+ Host: #{host}\n"  
            puts "| | | |  Changed files: #{@deployment_report[:deployed_files][tier][component][site][host].size}\n"  
            @deployment_report[:deployed_files][tier][component][site][host].each do |file|
              puts "| | | | \n"
              puts "| | | |-+ File: \n"
              puts "| | | | |  Src: #{file[:filename]}\n"
              puts "| | | | |  Dest: #{file[:dest_dir]}\n"

              puts "| | | | |  Did exists before copy: #{file[:copystats][:did_exist_before]}\n"
              puts "| | | | |  old ls: #{file[:copystats][:ls_before_copy]}" # the listing has carriage return in it
              puts "| | | | |  new ls: #{file[:copystats][:ls_after_copy]}" # the listing has carriage return in it      
            end
          
          end
        end
      end
    end
  end

  def patch_jars(seed_machine,seed_runtime_area,items,tier,component,site)
    @deployment_report[:patched_jars][tier] ||= {}
    @deployment_report[:patched_jars][tier][component] ||= {}
    @deployment_report[:patched_jars][tier][component][site] ||= {} 

    items.each do |item|
      @deployment_report[:patched_jars][tier][component][site][item[:dest]] ||= {} 

      patch_area = "#{post_release}/#{tier}/#{component}/#{site}/#{File.basename(item[:dest])}"
      mkdir_p patch_area
      puts "--- download #{seed_runtime_area}/#{item[:dest]}"
      seed_machine.download(:src=>"#{seed_runtime_area}/#{item[:dest]}",:dest=>patch_area)

      @deployment_report[:patched_jars][tier][component][site][item[:dest]][:seed_machine] = seed_machine.host
      @deployment_report[:patched_jars][tier][component][site][item[:dest]][:pre_release_site] = patch_area
   
      cd patch_area
      @deployment_report[:patched_jars][tier][component][site][item[:dest]][:patched_classes] ||= []
      @deployment_report[:patched_jars][tier][component][site][item[:dest]][:patched_classes].concat(
        update_jar(:src=>"#{release_dir}/#{item[:src]}", 
           :dest=>"#{patch_area}/#{File.basename(item[:dest])}",
           :jar=>jar))
      @deployment_report[:patched_jars][tier][component][site][item[:dest]][:src] = "#{release_dir}/#{item[:src]}"
      @deployment_report[:patched_jars][tier][component][site][item[:dest]][:dest] = "#{patch_area}/#{File.basename(item[:dest])}"
    end     
  end

  def each_site
    if target.to_s.downcase == "prod"
        yield "#{target}_tdc" if block_given?
        yield "#{target}_odc" if block_given?
    else
        yield target if block_given?
    end       
  end
 
end
