class Array
  def map_2x(&block)
    self.map { |x| block.call(x) * 2 }
  end
end

result = [0, 1, 2, 3].map_2x { |x| x + 1 }
puts result
