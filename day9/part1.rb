#!/usr/bin/env ruby

require 'set'

Instruction = Struct.new(:dir, :count)

Position = Struct.new(:x, :y)

def parse_instructions(stream)
  stream.each_line.map(&:chomp).map do |line|
    dir_str, count_str = line.split(' ')
    Instruction.new(dir_str.to_sym, count_str.to_i)
  end
end

def normalize_instructions(instructions)
  instructions.flat_map do |instruction|
    [Instruction.new(instruction.dir, 1)] * instruction.count
  end
end

def move(cur, dir)
  x_mod, y_mod = {
    U: [ 0, -1],
    R: [ 1,  0],
    D: [ 0,  1],
    L: [-1,  0]
  }[dir]
  Position.new(cur.x + x_mod, cur.y + y_mod)
end


def move_towards_head(tail, head)
  touching_on_x_axis = ((head.x - 1)..(head.x + 1)).include?(tail.x)
  touching_on_y_axis = ((head.y - 1)..(head.y + 1)).include?(tail.y)
  return tail if touching_on_x_axis && touching_on_y_axis

  tail_x_mod = (head.x <=> tail.x).clamp(-1, 1)
  tail_y_mod = (head.y <=> tail.y).clamp(-1, 1)

  Position.new(tail.x + tail_x_mod, tail.y + tail_y_mod)
end

instructions = normalize_instructions(parse_instructions(ARGF))

head = Position.new(0, 0)
tail = head
visited = Set[tail]

instructions.each do |instruction|
  head = move(head, instruction.dir)
  tail = move_towards_head(tail, head)
  visited << tail
end

puts visited.size