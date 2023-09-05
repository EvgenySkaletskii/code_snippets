# user.rb
class User
	attr_accessor :first_name, :last_name

	def initialize(first_name, last_name)
    @first_name = first_name
		@last_name = last_name
	end
end

# decorated_user.rb
require 'delegate'
class DecoratedUser < SimpleDelegator
  def full_name
    "#{first_name} #{last_name}"
  end
end

u = User.new("John", "Doe")
decorated_user = DecoratedUser.new(u)

decorated_user.full_name # => John Doe
decorated_user.first_name # => John
decorated_user.last_name # => Doe

#simple delegator может показать/поменять изначальный объект
decorated_user.__getobj__  #=> #<User: ...>
decorated_user.__setobj__(other_user)
