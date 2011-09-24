require 'yaml'

require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'net/ssh/gateway'

require File.dirname(__FILE__) + '/passwd'

class SSHConnection
  
  attr_reader :host

  def self.start(params) 
    t1 = Time.now
    
    shell = new(params)
    
    if block_given?
      begin
        yield shell
      ensure
        shell.close
      end
    end  
    
    t2 = Time.now
    
    puts "#{shell.host}: session complete in #{ '%10.6f' % (t2.to_f-t1.to_f)} seconds"
  end
  
  def initialize(params)
    @host = params[:host]

    @verbose = params[:verbose]

    #puts "--- #{self} verbose=#{params[:verbose]}"

    @verbose = if params[:verbose].nil?
      false
    else
      params[:verbose]
    end

    passwd_data = Passwd.new(params).passwd_data

    @hostspec= passwd_data.find{|p| p[:host]==@host}
    
    unless @hostspec
      raise "missing #{host} in passwd file"
    end
=begin    
    puts "---"
    require 'pp'
    pp @hostspec
=end    
    if @hostspec[:gateway]
      gateway_spec = passwd_data.find{|p| p[:host]==@hostspec[:gateway]}

      @ssh = connect_via_gateway(@hostspec,gateway_spec)
    else
      @ssh = connect_directly(@hostspec)
    end   
  end

  def connect_directly(spec)  
    if spec[:key]
      # puts "--- connect to #{spec[:host]} using key #{spec[:key]}"

      @ssh = Net::SSH.start(spec[:host],spec[:username],:keys =>[spec[:key]])    
    else
      @ssh = Net::SSH.start(spec[:host],spec[:username],:password =>spec[:password])    
    end
  end

  def connect_via_gateway(spec,gateway_spec)  
    if gateway_spec[:key]
      puts "--- connect to #{gateway_spec[:host]} using key #{gateway_spec[:key]}"
      @gateway = Net::SSH::Gateway.new(gateway_spec[:host],gateway_spec[:username],:keys =>[gateway_spec[:key]])
    else
      @gateway = Net::SSH::Gateway.new(gateway_spec[:host],gateway_spec[:username],:password =>gateway_spec[:password])
    end  

    if spec[:key]
      # puts "--- connect to #{spec[:host]} using key #{spec[:key]}"
      @ssh = @gateway.ssh(spec[:host],spec[:username],:keys=>spec[:key])  
    else
      @ssh = @gateway.ssh(spec[:host],spec[:username],:password =>spec[:password])  
    end   
  end  

  def close
    @ssh.close
    @gateway.shutdown! if @gateway
  end

end
