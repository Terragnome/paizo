module DM
  class Dice
    attr_reader :expected_value
    
    def initialize(sides)
      @sides = sides
      @expected_value = Array(1..sides).inject(:+)/sides.to_f
    end

    def roll(count=1)
      rolls = []
      count.times{ |a| rolls<<rand(@sides)+1 }
      rolls
    end
  end
end