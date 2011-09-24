require 'base64'
require 'thread'

class Passwd
  
  @@mutex = Mutex.new
  
  attr_reader :passwd_data,:passwd_file

  def initialize(params={})
     @passwd_file = params[:passwd_file] || '.passwd'
     
     unless File.exist?(@passwd_file)
       puts "password file '#{@passwd_file}' is not found"  
       exit(-1)
     end  

     @@mutex.synchronize do 
       @passwd_data = YAML.load(File.read(@passwd_file))
       if clear_password_exist? 
          puts "--- encrypt #{@passwd_file}"
          encrypt
       end
       decrypt
=begin       
       @passwd_data.each do |p|
         if p[:key]
           p[:key] = File.expand_path(p[:key])
           p[:key] = File.dirname(File.expand_path(@passwd_file)) + "/#{p[:key]}" unless File.exists?(p[:key])
         end
       end
=end
    end   
  end

  def clear_password_exist?
=begin
     puts "--- "
     require 'pp'
     pp @passwd_data
=end     
     
     @passwd_data.any?{|p| p[:password] }
  end

  def encrypt
     @passwd_data.each do |p|
       if p[:password]
         p[:secret] = Base64.encode64(p[:password].to_s) 
         p[:password]=nil
       end
     end

     File.open(@passwd_file,'w') do |f|        
        puts "--- \n#{@passwd_data.to_yaml}"
        f.puts @passwd_data.to_yaml
     end
  end

  def decrypt
     @passwd_data.each do |p|
       if p[:secret]
         p[:password]= Base64.decode64(p[:secret]) 
=begin         
         puts "---" 
         require 'pp'
         pp p
         p[:secret]=nil
=end         
       end  
     end
  end

end
