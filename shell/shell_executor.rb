require File.dirname(__FILE__) + '/ssh_connection'
require File.dirname(__FILE__) +'/core_ext'

require 'fileutils'
require 'erb'

include FileUtils

class ShellExecutor < SSHConnection
  
  def initialize(params)
    #puts "--- #{self} verbose=#{params[:verbose]}"
    
    super params

    if params[:dry].nil?
       @dry = false
    else
       @dry = params[:dry]
    end   
  end
  
  def timestamp
    now = Time.now
    "#{now.strftime("%Y-%m-%d-%H-%M-%S")}-#{"%03d" % (now.usec/1000)}"
  end  
  
  def upload_dir(params)     
    remote_dir = params[:remote_dir]
    local_dir = params[:local_dir]
    exclude = params[:exclude]

    Dir["#{local_dir}/**/*"].each do |fname|
      if FileTest.file?(fname)
        dest = "#{remote_dir}#{File.dirname(fname).sub(local_dir,'')}"
        puts "[#{@hostspec[:host]}] --- upload #{fname} to #{dest}" if @verbose
        exec("mkdir -p #{dest}") 
        @ssh.scp.upload!(fname,dest)
      end 
    end   
     
  end

  def download_dir(params)
    remote_dir = params[:remote_dir]
    local_dir = params[:local_dir]
    exclude = params[:exclude]
    
    filelist = find(:remote_dir=>remote_dir, :exclude=>exclude)

    filelist.each do |fname|
      dest = "#{local_dir}#{File.dirname(fname).sub(remote_dir,'')}"
      mkdir_p dest

      rm_rf "#{dest}/#{File.basename(fname)}"
      download(:src=>fname,:dest=>dest)
    end

  end

  def download(params)
    puts "--- download #{host}:#{params[:src]} => #{params[:dest]}" if @verbose
    @ssh.scp.download!(params[:src],params[:dest]) unless @dry
  end

  def upload(params)
    puts "--- upload #{params[:src]} => #{host}:#{params[:dest]}"
    @ssh.scp.upload!(params[:src], params[:dest]) unless @dry
  end

  def satisfied?(patterns,basename)
   patterns.to_a.each do |one|
	#puts "--- satisfield? #{one}"
     return true if basename =~ Regexp.new(one,Regexp::IGNORECASE)
   end
   return false
  end  

  def mail(params)
      now = Time.now

      script_template=<<EOS 
mail -s <%=params[:subject].strip.dump%> -c "<%=params[:cc].to_a.join(' ')%>" -r <%=params[:mymail]%> <%=params[:to]%> < <%=params[:mail_body_file]%>
EOS

      params[:mail_body_file] = "/tmp/auto_alert_mail_#{now.strftime('%Y_%m_%d_%H_%M_%S')}.txt"

      script =  ERB.new(script_template).result(binding)

      create_file(:path=>params[:mail_body_file],:content=>params[:body])

      exec(script)

      exec("rm -f #{params[:mail_body_file]}")
  end

  def create_file(params)
     path = params[:path] 
     content = params[:content]
   
     local_path = File.basename(path)

     puts "--- local_path=#{local_path}"
     puts "--- remote_path=#{path}"

     File.open(File.basename(path),'w') do |f|
       f.write(content)
     end

     @ssh.scp.upload!(local_path,path)
     puts "[#{@hostspec[:host]}] --- upload #{local_path} => #{path}" 

     rm_f local_path
     
  end

  def find(params)
    remote_dir = params[:remote_dir]
    exclude = params[:exclude]

    filelist = exec("find \"#{remote_dir}\" -type f").split("\n").select { |fname|
      not satisfied?(exclude,fname)
    }

    return filelist
     
  end

  def ls(fname)
    exec("ls -l #{fname}")
  end

  def exist?(filename)
    not exec("if [ -f #{filename} ]; then echo true; fi").to_s.strip.empty?
  end

  def exec(script)     
    puts "#{host}: exec =>\n#{script}\n---\n" if @verbose

    result = @ssh.exec!(script)     
    
    puts "#{host}: return =>\n#{result}\n---\n" if @verbose

    result 
  end
  
  def close
    super
    puts "--- disconnected from the server: #{host} at '#{Time.now.strftime('%Y/%m/%d %H:%M.%S')}'"
  end

  def copy_in_location(params)
    script = "cd \"#{params[:location]}\"; cp -R \"#{params[:src]}\" \"#{params[:dest]}\" "
    if params[:dry]
       puts "--- #{host}: DRY run #{script}"
    else
       exec(script)
    end   
  end  

end

UnixBox = ShellExecutor
