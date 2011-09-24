class KeyDB

  def initialize(data)
    @data = data
  end

  def add(data)
    @data = @data + data
  end

  def select(where)
    
    result = @data.select{|e| where.all?{|k,v| v.nil? or [*e[k]].include?(v) } }

    if block_given?
      result.collect {|e| yield e} 
    else
      result
    end  
  end

end

