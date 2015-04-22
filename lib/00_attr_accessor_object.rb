class AttrAccessorObject
  def self.my_attr_accessor(*names)

    names.each do |name|
      ivar_name = "@#{name}"

      define_method(name) do
        instance_variable_get(ivar_name)
      end


      define_method("#{name}=") do |other|
        instance_variable_set(ivar_name, other)
      end
    end

  end
end
