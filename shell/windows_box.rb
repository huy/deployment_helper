require 'fileutils'
include FileUtils

class WindowsBox
  attr_reader :host

  def initialize(params)
    @host = params[:host]

    @dry = if params[:dry].nil?
      false
    else
      params[:dry]
    end

    @verbose = if params[:verbose].nil?
      false
    else
      params[:verbose]
    end
  end

  def download(params)
    puts "--- download //#{host}/#{params[:src]} => #{params[:dest]}" if @verbose
    cp "//#{host}/#{params[:src]}", params[:dest] unless @dry
  end

  def upload(params)
    puts "--- upload #{params[:src]} => //#{host}/#{params[:dest]}"
    cp params[:src], "//#{host}/#{params[:dest]}" unless @dry
  end

  def ls(fname)
    puts "--- ls -l #{fname}"
    result = open("| ls -l //#{host}/#{fname}").read
    puts "---"      
    result
  end

  def exist?(fname)
    result = open("| ls -l //#{host}/#{fname}").read
    return (not result.strip.empty?)
  end

  def download_dir(params)
    remote_dir = params[:remote_dir]
    local_dir = params[:local_dir]
    exclude = params[:exclude]
    
    filelist = find(:remote_dir=>remote_dir, :exclude=>exclude)

    filelist.each do |fname|

      dest = "#{local_dir}#{File.dirname(fname).sub("#{host}/#{remote_dir}",'')}"

      puts "--- #{fname} => #{dest}" if @verbose   

      mkdir_p dest

      cp fname, dest
  
    end
  end
  
  def find(params)
    remote_dir = params[:remote_dir]
    exclude = params[:exclude]

    filelist = Dir["//#{host}/#{remote_dir}/**/*"].select { |fname|
      not File.directory?(fname) and not satisfied?(exclude,fname)
    }

    return filelist
  end

  def satisfied?(patterns,basename)
   patterns.to_a.each do |one|
   #puts "--- satisfield? #{one}"
     return true if basename =~ Regexp.new(one,Regexp::IGNORECASE)
   end
   return false
  end  

  def close
  end

end
