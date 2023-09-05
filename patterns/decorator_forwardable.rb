# user.rb
class User
	attr_accessor :first_name, :last_name

	def initialize(first_name, last_name)
    @first_name = first_name
		@last_name = last_name
	end
end


# decorated_user.rb
require 'forwardable'

class DecoratedUser
  extend Forwardable

  def_delegators :@user, :first_name, :last_name

  def initialize(user)
    @user = user
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

u = User.new('John', 'Doe')
decorated_user = DecoratedUser.new(u)

decorated_user.full_name # => John Doe
decorated_user.first_name # => John
decorated_user.last_name # => Doe
