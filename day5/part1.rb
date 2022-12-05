#!/usr/bin/env ruby

def parse_stacks(stack_str)
  stacks = Hash.new {|h, k| h[k] = []}
  stack_str.reverse[2..-1].each do |stack_line|
    stack_line.chars.each_slice(4).map {|a| a[1]}.each_with_index do |sym, idx|
      stacks[idx].push(sym) if sym != ' '
    end
  end
  (0..stacks.keys.max).map {|idx| stacks[idx]}
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