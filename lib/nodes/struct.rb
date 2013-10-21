module Doxyparser

  class Struct < Compound
  	
  	attr_reader :file
  	attr_reader :friends
  	attr_reader :template_params
  	
  	def init_attributes
  		super
  		@file = init_file
  		@friends = init_friends
  		@template_params = init_template_params
  	end

    def init_file
      n = doc.xpath("/doxygen/compounddef/includes")[0]
      return n ? HFile.new(dir: @dir, node: n) : nil 
    end

    def init_friends
      lst=doc.xpath(%Q{/doxygen/compounddef/sectiondef[@kind="friend"]/memberdef[@kind="friend"]})
      lst.map { |node|
        Doxyparser::Friend.new(parent: self, node: node)
      }
    end

    def init_template_params
      params=doc.xpath(%Q{/doxygen/compounddef/templateparamlist/param})
      params.map { |param|
        Doxyparser::Param.new(parent: self, node: param)
      }
    end
    
    def methods(access = :public, static = nil, filter = nil)
    	get_methods(access, static, filter)
    end

    def get_methods(access = :public, static = nil, filter = nil)
    	if access == :all
    		return methods(:public, static, filter) + methods(:protected, static, filter) + methods(:private, static, filter)
    	end
      if static.nil?
        static = "-"
      else
        static = "-static-"
      end
      sectiondef = %Q{#{access}#{static}func}
      lst = doc.xpath(%Q{/doxygen/compounddef/sectiondef[@kind="#{sectiondef}"]/memberdef[@kind="function"][@prot="#{access}"]})
      do_filter(filter, lst, Doxyparser::Function) { |node|
        node.xpath("name")[0].child.content
      }
    end

    def attributes(access = :public, static = nil, filter = nil)
    	if access == :all
    		return attributes(:public, static, filter) + attributes(:protected, static, filter) + attributes(:private, static, filter) 
    	end
      if static.nil?
        static = "-"
      else
        static = "-static-"
      end
      sectiondef = %Q{#{access}#{static}attrib}
      lst = doc.xpath(%Q{/doxygen/compounddef/sectiondef[@kind="#{sectiondef}"]/memberdef[@kind="variable"][@prot="#{access}"]})
      do_filter(filter, lst, Doxyparser::Variable) { |node|
        node.xpath("name")[0].child.content
      }
    end
    
    def innerclasses(access = :public, filter = nil)
    	if access == :all
    		return innerclasses(:public, filter) + innerclasses(:protected, filter) + innerclasses(:private, filter) 
    	end
    	return only_innerclasses(access, filter) + only_innerstructs(access, filter)
    end

    def only_innerclasses(access = :public, filter = nil)
    	if access == :all
    		return innerclasses(:public, filter) + innerclasses(:protected, filter) + innerclasses(:private, filter) 
    	end
      lst = doc.xpath(%Q{/doxygen/compounddef/innerclass[@prot="#{access}"]})
      lst = lst.select { |c| c["refid"].start_with?("class") }
      do_filter(filter, lst, Doxyparser::Class) { |node|
        del_prefix(node.child.content)
      }
    end

    def only_innerstructs(access = :public, filter = nil)
    	if access == :all
    		return innerstructs(:public, filter) + innerstructs(:protected, filter) + innerstructs(:private, filter) 
    	end
      lst = doc.xpath(%Q{/doxygen/compounddef/innerclass[@prot="#{access}"]})
      lst = lst.select { |c| c["refid"].start_with?("struct") }
      do_filter(filter, lst, Doxyparser::Struct) { |node|
        del_prefix(node.child.content)
      }
    end
    
    def parent_types(access = :public, filter = nil)
    	if access == :all
    		return parent_types(:public, filter) + parent_types(:protected, filter) + parent_types(:private, filter) 
    	end
      types = doc.xpath(%Q{/doxygen/compounddef/basecompoundref[@prot="#{access}"]})
      types.map { |t|
      	Doxyparser::Type.new(name: t.child.content, dir: @dir)
      }
    end

    def enums(access = :public, filter = nil)
    	if access == :all
    		return enums(:public, filter) + enums(:protected, filter) + enums(:private, filter) 
    	end
      sectiondef = %Q{#{access}-type}
      lst = doc.xpath(%Q{/doxygen/compounddef/sectiondef[@kind="#{sectiondef}"]/memberdef[@kind="enum"][@prot="#{access}"]})
      filter.map!{ |exp| exp =~ /^#{@basename}_Enum/ ? /@\d*/ : exp} unless filter.nil?
      do_filter(filter, lst, Doxyparser::Enum) { |node|
        node.xpath("name")[0].child.content
      }
    end

    def typedefs(access = :public, filter = nil)
    	if access == :all
    		return typedefs(:public, filter) + typedefs(:protected, filter) + typedefs(:private, filter) 
    	end
      sectiondef = %Q{#{access}-type}
      lst = doc.xpath(%Q{/doxygen/compounddef/sectiondef[@kind="#{sectiondef}"]/memberdef[@kind="typedef"][@prot="#{access}"]})
      do_filter(filter, lst, Doxyparser::Typedef) { |node| 
      	del_spaces node.xpath("name")[0].child.content
      }
    end

    private

    def compute_path
      aux = escape_class_name(@name)
      @xml_path = %Q{#{@dir}/struct#{aux}.xml}
    end
  end
end