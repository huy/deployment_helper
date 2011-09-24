require 'fileutils'
require File.dirname(__FILE__) + '/../shell/shell_executor'
require File.dirname(__FILE__) + '/class_deployer'
require File.dirname(__FILE__) + '/file_deployer'
require File.dirname(__FILE__) + '/env_config'
require File.dirname(__FILE__) + '/deployment_manager'

include FileUtils

def log_output(filename,filemode="a") 
  File.open(filename,filemode) do |f|
    original = $stdout
    begin
      $stdout = f
      yield if block_given?
    ensure
      $stdout = original
    end
  end
end


