#!/usr/bin/env ruby

class Screen
  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @pixels = height.times.map { width.times.map { '.' } }
  end

  def []=(x, y, lit)
    @pixels[y][x] = lit ? '#' : '.'
  end

  def to_s
    @pixels.map {|line| line.join('')}.join("\n")
  end
end

x_reg = 1
clock = 0

instructions = ARGF.each_line.map(&:chomp).flat_map do |inst|
  case inst.split(' ')
    in ['noop']
      [{ op: :noop }]
    in ['addx', v]
      # addx takes two cycles before the value is added.
      # We simulate that by turning it into a noop and and then a 1 cycle add.
      [{ op: :noop }, { op: :addx, v: v.to_i }]
  end
end

screen = Screen.new(40, 6)

instructions.each do |inst|
  x = clock % screen.width
  y = clock / screen.width

  screen[x, y] = (x - x_reg).abs <= 1
  clock += 1

  case inst
    in { op: :noop }
    in { op: :addx, v: v }
      x_reg += v
  end
end

puts screen