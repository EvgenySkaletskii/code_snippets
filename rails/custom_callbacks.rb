require 'active_support/all'

class Foo
  include ActiveSupport::Callbacks

  define_callbacks :validate

  set_callback :validate, :before, :validate!

  def save(value)
    run_callbacks :validate do
      p value
    end
  end

  def validate!
    p 'validation is performing'
  end
end

foo = Foo.new
foo.save('some value')
