module Doxyparser

  class Function < Member

    def == another
      super
      self.args == another.args
    end

    def eql?(another)
      super
      self.args == another.args
    end

    def to_str
      super + @args
    end

    def to_s
      super + @args
    end

    def constructor?
      @basename == parent.basename
    end

    def destructor?
      @basename.start_with? %Q{~}
    end

    def getter_for
      if @params.empty? || (@params.size == 1 && @params[0].type.name =~ /\s*void\s*/)
        if @basename.start_with?('get') || @basename.start_with?('Get')
          return @basename.gsub(/get[_]?(\w)/i) { |match| $1.downcase }
        end
        if @type.name == 'bool'
          if @basename.start_with?('is') || @basename.start_with?('Is')
            return @basename.gsub(/is[_]?(\w)/i) { |match| $1.downcase }
          end
        end
      end
      return nil
    end

    def setter_for
      if @type.name == 'void'
        if @basename.start_with?('set') || @basename.start_with?('Set')
          return @basename.gsub(/set[_]?(\w)/i) { |match| $1.downcase }
        end
      end
      return nil
    end
  end
end