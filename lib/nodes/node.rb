class DoxyNode
  include DoxyParser
  
  attr_reader :dir
  attr_reader :name
  attr_reader :node
  attr_reader :parent
  #@doc
  attr_reader :path
  
  def == another
    self.name == another.name
  end
  
  def to_str
    @name
  end
  
  def eql? another
    self.class == another.class && self.name == another.name
  end
  
  def doc
    if @doc==nil
      parse
    end
    @doc
  end
 
  def method_missing sym, *args
    raise DoxyException::no_node_assoc(@name, self.class.name) unless @node
    if @node.respond_to? sym
       @node.send(sym,*args)
    else
      @node[sym.to_s] || super  
    end     
  end
  
  def initialize hash
    @doc = nil
    @path = nil 
    # If an explicit name is given it takes precedence  
    if hash[:name]
      @name = hash[:name]      
    end
    # If an explicit directory is given it takes precedence  
    if hash[:dir]
      @dir = hash[:dir]      
    end
    # If a reference to an xml declaration (node) is given
    if hash[:node]
      # A parent must also be given      
      if hash[:parent]
        @parent = hash[:parent]
        @dir ||= parent.dir # Only if @dir is nil
      else
        raise DoxyException::no_parent_assoc(@name, self.class.name)
      end
      # Default name if a node is given
      @node= hash[:node]
      @name ||= self.xpath("name").child.content                  
    end 
    compute_attr  
  end
  
  def parse    
    raise DoxyException::no_file_assoc(@name, self.class.name, @path) unless File.exists? @path
    if File.extname(@path)==".xml"
      File.open(path){ |namespace|         
         @doc=Nokogiri::XML(namespace)        
      }  
    else
      @doc = @node
    end
    self   
  end
  
  private
  
  def compute_attr
    if @node 
       @path = %Q{#{@dir}/#{self.id}.xml}
    end
  end
end