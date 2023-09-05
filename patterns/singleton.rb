require 'singleton'

class Shop
  include Singleton
end

Shop.new # => NoMethodError: private method `new' called for Shop:Class

Shop.instance.object_id # 56784
Shop.instance.object_id # 56784
