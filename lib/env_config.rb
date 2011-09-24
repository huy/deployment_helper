require File.dirname(__FILE__) + '/../shell/shell_executor'
require File.dirname(__FILE__) + '/../shell/windows_box'

require File.dirname(__FILE__) + '/key_db'
require File.dirname(__FILE__) + '/prod_config'
require File.dirname(__FILE__) + '/test_config'

def password_file 
  passwd = ENV['passwd']  || ENV['PASSWD'] || 'd:/personal/keystore/.passwd'
  passwd.gsub("\\","/")
end

def config_db
  @config_db ||= KeyDB.new(PROD_CONFIG + TEST_CONFIG)
end  

def release_root
  @release_root ||= {}
  @release_root[:ocrm] ||= "r:/release/"
  @release_root[:cube] ||= @release_root[:ocrm] 
  @release_root[:zngn] ||= @release_root[:ocrm]
  @release_root[:tpny] ||= "r:/Release Dir for Avaya/Avaya"
  @release_root
end  

def stage_root
  dir = ENV['stage_root'] || ENV['STAGE_ROOT'] || "d:/huy/release"
  dir.gsub("\\","/")
end

def utl_subsystem_hosts(site, subsystem, instance=nil)

  result = config_db.select(:site=>site.to_s.downcase.to_sym,
                             :subsystem=>subsystem.to_s.downcase.to_sym,
                             :instance=>instance)

  result = result.reject {|entry| entry[:host].nil?}

  if result.empty?
    raise "-- no corresponding configuration found for site: #{site}, subsystem: #{subsystem}"
  end

  @hosts ||= {}
  result.collect do |entry| 
    puts "-- entry[:host]=#{entry[:host]}"

    entry[:machine_type] ||= UnixBox

    unless @hosts[entry[:host]]
      @hosts[entry[:host]] = entry[:machine_type].new(:host=>entry[:host],
                                                      :passwd_file=>password_file, 
                                                      :verbose=>true)
    end  

    @hosts[entry[:host]]
  end

end

def utl_component_dir(site, subsystem, component, instance=nil)
  result = config_db.select(:site=>site.to_s.downcase.to_sym,
                            :subsystem=>subsystem,
                            :component=>component, 
                            :instance=>instance)

  result = result.collect {|entry| entry[:location]}

  if result.empty?
    raise "-- no corresponding configuration found for site: #{site}, subsystem: #{subsystem}, component: #{component}"
  end

  if result.size > 1
    raise "-- more than one configuration found for site: #{site}, subsystem: #{subsystem}, component: #{component}\n\t #{result.join("\n\t")}"
  end
  
  result
end

