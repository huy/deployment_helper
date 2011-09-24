require 'fileutils'
include FileUtils

require File.dirname(__FILE__) + '/env_config'

def safe_remote_copy(params)
  copy_stats = {}
  remote_machine = params[:remote_machine]

  filename = params[:filename] || params[:fname] 
  dest_dir = params[:dest_dir] || params[:dest]
  backup_dir = params[:backup_dir] || param[:backup] # full path of location where to keep original file

  dry = if params[:dry].nil?
    false
  else
    params[:dry]
  end 

  copy_stats[:ls_before_copy] = remote_machine.ls("#{dest_dir}/#{File.basename(filename)}")
  copy_stats[:did_exist_before] = remote_machine.exist?("#{dest_dir}/#{File.basename(filename)}")


  if backup_dir
    mkdir_p backup_dir

    if remote_machine.exist?("#{dest_dir}/#{File.basename(filename)}")
       remote_machine.download(:src=>"#{dest_dir}/#{File.basename(filename)}",
                    :dest=> backup_dir)
    end                  
  end

  if dry
    puts "--- DRY run upload #{filename} to #{remote_machine.host}:#{dest_dir}"
  else
    remote_machine.upload(:src=>filename,:dest=>dest_dir)
  end

  copy_stats[:ls_after_copy] = remote_machine.ls("#{dest_dir}/#{File.basename(filename)}")
  copy_stats
end

def utl_deploy_files(params)
  deployed_files = []
  release_dir = params[:release_dir]
  pre_release = params[:pre_release]
  remote_machine = params[:remote_machine]
  runtime_area = params[:runtime_area] 
  items = params[:items]

  items.each do |item|
=begin
    require 'pp'
    puts "--- item to be deployed"
    pp item
=end
    Dir["#{release_dir}/#{item[:src]}"].each do |fname|
   
      dest_dir = "#{runtime_area}/#{item[:dest]}"
      pre_release_backup = "#{pre_release}/#{remote_machine.host}/#{item[:dest]}"

      copy_stats = safe_remote_copy(:remote_machine=>remote_machine,
                       :filename=>fname,
                       :dest_dir=>dest_dir,
                       :backup_dir=>pre_release_backup,
                       :dry=>params[:dry])
      deployed_files << {:filename=>fname,:dest_dir=>dest_dir,:backup_dir=>pre_release_backup, :copystats =>copy_stats}
    end

  end
  deployed_files
end


