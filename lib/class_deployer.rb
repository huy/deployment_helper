require 'fileutils'
require File.dirname(__FILE__) + '/java_class_info'

def jar
  jar = ENV['jar'] || ENV['JAR'] || "c:/j2sdk1.4.2_14/bin/jar"
  jar.gsub("\\","/")
end

include FileUtils

def update_jar(params)
  patch_stats = []
  src = params[:src]
  dest = params[:dest]
  jar = params[:jar]

  pattern = if File.directory?(src)
     "#{src}/**/*.class"
  else
     src
  end

  puts "--- update #{File.basename(dest)} by #{pattern}"

  Dir[pattern].each do |fname|
    puts "--- read #{File.basename(fname)}" 
    info = JavaClassInfo.read(fname)
    puts "--- classname=#{info.this_class_name}"
    patch_stats << {:classname=>info.this_class_name, :filename=>fname}
    package_dir = "#{File.dirname(dest)}/classes/#{File.dirname(info.this_class_name)}"
    puts "--- create #{package_dir}"
    mkdir_p "#{package_dir}"
  
    puts "--- copy #{fname} to #{package_dir}"
    cp fname, package_dir
  
  end

  cd "#{File.dirname(dest)}/classes"

  jar_cmd = "#{jar} uf #{dest} *"
  
  puts "--- run #{jar_cmd}"
  
  system jar_cmd

  patch_stats
end

def deploy_ear_files(params)

    params[:release_dir] ||= release_dir
    params[:pre_release] ||= pre_release
    params[:dry] ||= dry_mode
    params[:items] = params[:items].to_a
    tier = params[:tier]
    component = params[:component]

    if target.to_s.downcase == "prod"
      utl_tier("#{target}_tdc",tier).each do |host|
        params[:remote_machine] = host
        params[:runtime_area] = installed_apps[component]["#{target}_tdc".to_sym]
        utl_deploy_files(params)
      end  
      utl_tier("#{target}_odc",tier).each do |host|
        params[:remote_machine] = host
        params[:runtime_area] = installed_apps[component]["#{target}_odc".to_sym]
        utl_deploy_files(params)
      end  
    else
      utl_tier(target,tier).each do |host|
        params[:remote_machine] = host
        params[:runtime_area] = installed_apps[component][target.to_sym]
        utl_deploy_files(params)
      end  
    end  

end

def utl_deploy_jars(params)      
  deployed_files = []  
  pre_release = params[:pre_release]
  post_release = params[:post_release]
  remote_machine = params[:remote_machine]
  base_location = params[:base_location] || params[:runtime_area] 
  items = params[:items] 

  items.each do |item|
    fname = "#{post_release}/#{File.basename(item[:dest])}/#{File.basename(item[:dest])}"
    puts "--- utl_deploy_jars fname = #{fname}"
    dest_dir = "#{base_location}/#{File.dirname(item[:dest])}"
    
    pre_release_backup = if pre_release
      "#{pre_release}/#{remote_machine.host}/#{File.dirname(item[:dest])}"
    else
      nil  
    end

    copy_stats = safe_remote_copy(:remote_machine=>remote_machine,
                     :filename=>fname,
                     :dest_dir=>dest_dir,
                     :backup_dir=>pre_release_backup,
                     :dry=>params[:dry])

    deployed_files << {:filename=>fname,:dest_dir=>dest_dir,:backup_dir=>pre_release_backup, :copystats =>copy_stats}
  end   
  deployed_files
end

