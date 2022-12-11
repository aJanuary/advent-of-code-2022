#!/usr/bin/env ruby

Monkey = Struct.new(:idx, :items, :operation, :div_test, :true_branch, :false_branch)

class Operation
  def self.parse(str)
    op, rhs = str[10..-1].split(' ')
    op = op.to_sym
    rhs = rhs == 'old' ? rhs.to_sym : rhs.to_i
    Operation.new(op, rhs)
  end

  def evaluate(old)
    rhs_evaluated = @rhs == :old ? old : @rhs
    case @op
    when :+
      old + rhs_evaluated
    when :*
      old * rhs_evaluated
    end
  end

private
  def initialize(op, rhs)
    @op = op
    @rhs = rhs
  end
end

def parse_monkey(stream)
  monkey = Monkey.new(
    idx = stream.readline.scan(/\d+/).map(&:to_i).first,
    items = stream.readline.scan(/\d+/).map(&:to_i),
    operation = Operation.parse(stream.readline[13...-1]),
    div_test = stream.readline.scan(/\d+/).map(&:to_i).first,
    true_branch = stream.readline.scan(/\d+/).map(&:to_i).first,
    false_branch = stream.readline.scan(/\d+/).map(&:to_i).first
  )
  stream.readline unless stream.eof
  monkey
end

def parse_monkies(stream)
  monkies = []
  until stream.eof? do
    monkies << parse_monkey(stream)
  end
  monkies
end

monkies = parse_monkies(ARGF)

inspection_count = monkies.map { 0 }

# TODO: The numbers get real big real fast, which makes it real slow.
#       Need to find a way to limit the size of the numbers.
#       I _think_ dividing by the product of all the div_tests would work?
10000.times do |i|
  monkies.each do |monkey|
    monkey.items.each do |worry_level|
      worry_level = monkey.operation.evaluate(worry_level)
      throw_to_idx = worry_level % monkey.div_test == 0 ? monkey.true_branch : monkey.false_branch
      monkies[throw_to_idx].items << worry_level
    end
    inspection_count[monkey.idx] += monkey.items.size
    monkey.items = []
  end
end

pp inspection_count.max(2).inject(:*)