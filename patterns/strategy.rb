# fly_behaviour.rb
module FlyBehaviour
  class FlyWings
    def fly
      p 'flying with wings'
    end
  end

  class JetFLy
    def fly
      p 'flying like rocket'
    end
  end

  class NoFly
    def fly
      p 'cannot fly'
    end
  end
end

# quack_behaviour.rb
module QuackBehaviour
  class Quack
    def quack
      p 'QUACK!'
    end
  end

  class Squeak
    def quack
      p 'SQUEAK!'
    end
  end

  class Muted
    def quack; end
  end
end

# duck.rb
require './fly_behaviour'
require './quack_behaviour'

class Duck
  attr_accessor :fly_behaviour, :quack_behaviour

  def perform_fly
    @fly_behaviour.fly
  end

  def perform_quack
    @quack_behaviour.quack
  end

  def swim
    p 'all ducks can swim'
  end
end

# forest_duck.rb
class ForestDuck < Duck
  def initialize
    @fly_behaviour = FlyBehaviour::FlyWings.new
    @quack_behaviour = QuackBehaviour::Quack.new
  end
end

# rubber_duck.rb
class RubberDuck < Duck
  def initialize
    @fly_behaviour = FlyBehaviour::NoFly.new
    @quack_behaviour = QuackBehaviour::Squeak.new
  end
end

#################
duck = ForestDuck.new
duck.perform_fly # 'flying with fings'
duck.perform_quack # 'QUACK!'

duck.fly_behaviour = FlyBehaviour::JetFly.new # added engines to duck
duck.perform_fly # 'flying like rocket
