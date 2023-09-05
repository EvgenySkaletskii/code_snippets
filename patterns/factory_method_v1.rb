class User
  attr_accessor :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end
end

class Admin < User
end

class UserFactory
  def self.create(type)
    case type
    when 'admin'
      Admin.new
    when 'member'
      Member.new
    else
      Guest.new
    end
  end
end

class Endpoint
  def foo(params)
    user = UserFactory.create(params[:user_type])
    # some operations with user
  end
end
