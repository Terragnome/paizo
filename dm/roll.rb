require 'mactts'

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

  class DiceRoll
    attr_accessor :results
    attr_reader :expected_value

    def initialize(dice, count=1)
      @results = dice.roll(count)
      @expected_value = dice.expected_value*count
    end

    def method_missing(name, *args)
    end

    def sum
      @results.inject(:+)
    end
  end

  class Stats    
    def generate(count=1)
      num_sides = 6
      num_dice = 4

      results = []
      count.times do |i|
        dice = Dice.new(num_sides)
        rolls = DiceRoll.new(dice, num_dice)
        rolls.results = rolls.results.sort[1..count]
        results << "#{rolls.results} = #{rolls.sum}"
      end
      results.join("\n")
    end
  end

  class Roll
    @@roll_regex = /[0-9]*d[0-9]+/
    @@non_math_regex = /[a-z]*/

    def self.evaluate(commands)
      formulas = commands.split(';')
      results = []
      formulas.each{|i| results << "#{self.evaluate_formula(i.strip)}" }
      "#{results.join("\n\n**********\n\n")}"
    end

    #@TODO consolidate with dynamic programming
    def self.evaluate_formula(formula)
      #check for 0d0?
      operations = formula.gsub(@@roll_regex){|match| self.roll(match, :sum)}
      sum_operations = instance_eval( operations.split(@@non_math_regex).join('') )

      ev = formula.gsub(@@roll_regex){|match| self.roll(match, :expected_value)}
      sum_ev = instance_eval( ev.split(@@non_math_regex).join('') )

      eval_overflow = (sum_operations-sum_ev).to_f/sum_ev

      say "Rolled #{formula}"
      if eval_overflow<-0.75
        say "Fucking bullshit.  #{sum_operations}.  "
      elsif eval_overflow<-0.5
        say "Shit.  Got #{sum_operations}"
      elsif eval_overflow>0.75
        say "Critical!  Got #{sum_operations}"
      elsif eval_overflow>0.5
        say "Woo!  Got #{sum_operations}"
      else
        say "Got #{sum_operations}"
      end

      "#{operations} = #{sum_operations}\n#{formula}\nEV:#{sum_ev} | #{sum_operations} (#{eval_overflow>0 ? '+' : ''}#{(eval_overflow*100).round(2)}%)"
    end

    def self.say(sentence)
      Mac::TTS.say(sentence, :alex)
    end

    def self.roll(formula, method=:sum)
      values = formula.split("d")  
      count = values[0] && values[0].length == 0 ? 1 : values[0].to_i
      sides = values[1].to_i

      if sides>0 && count>0
        dice = DM::Dice.new(sides)
        rolls = DM::DiceRoll.new(dice, count)
        "(#{rolls.send(method)})"
      else
        0
      end
    end
  end
end