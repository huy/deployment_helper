
Time.class_eval do
  def to_s
     "#{strftime("%d-%m-%Y %H:%M:%S")}:#{'%03d' % (usec/1000)}"  
  end
end

