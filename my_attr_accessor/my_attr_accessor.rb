# frozen_string_literal: true

class Module
  def my_attr_accessor(*attrs)
    attrs.each do |attr|
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end

      define_method("#{attr}=") do |value|
        instance_variable_set("@#{attr}", value)
      end
    end
  end
end

class User
  my_attr_accessor :name, :age
end

user = User.new
user.name = 'Bob'
user.age = 25
p user.name
p user.age
