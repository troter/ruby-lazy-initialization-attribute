# add lazy initialization attribute definition
module LazyInitializationAttribute
  def LazyInitializationAttribute.append_features(mod)
    super

    def mod.lazy_attr_accessor name, hook=nil, &block
      lazy_attr_reader name, hook, &block
      attr_writer name
    end

    def mod.lazy_attr_reader name, hook=nil, &block
      raise 'Hook method name or block required' unless !hook.nil? || block
      block = block_given? ? block : Proc.new do
        self.respond_to?(hook.to_sym) ? self.send(hook.to_sym) : nil
      end
      self.send :define_method, name.to_sym do
        var_name = "@#{name}"
        unless instance_variable_defined? var_name
          result = instance_eval &block
          unless instance_variable_defined? var_name
            instance_variable_set(var_name, result)
          end
        end
        instance_variable_get var_name
      end
    end
  end
end
