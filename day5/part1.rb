#!/usr/bin/env ruby

def parse_stacks(stack_str)
  stack_str = stack_str[0...-1].reverse
  num_stacks = stack_str[0].split(" ").size
  stacks = num_stacks.times.map { [] }

  stack_str[1..-1].each do |stack_line|
    (0...num_stacks).each do |stack_idx|
      to_push = stack_line[(stack_idx * 4) + 1]
      stacks[stack_idx].push(to_push) if to_push != ' '
    end
  end
  stacks
end

def parse_instruction(instruction_str)
  count, from_idx, to_idx = instruction_str.scan(/move (\d+) from (\d+) to (\d+)/)[0].map(&:to_i)
  [count, from_idx - 1, to_idx - 1]
end

stack_str, instructions_str = ARGF.each_line.map(&:chomp).slice_when {|s| s == ''}.to_a

stacks = parse_stacks(stack_str)

instructions = instructions_str.map {|instruction_str| parse_instruction(instruction_str)}
instructions.each do |count, from_idx, to_idx|
  count.times do
    stacks[to_idx].push(stacks[from_idx].pop())
  end
end

top_of_stacks = stacks.map {|stack| stack[-1]}
puts top_of_stacks.join