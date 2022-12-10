#!/usr/bin/env ruby

x_reg = 1
clock = 1

sample_points = [20, 60, 100, 140, 180, 220]
samples = []

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

instructions.each do |inst|
  case inst
    in { op: :noop }
    in { op: :addx, v: v }
      x_reg += v
  end

  clock += 1
  if clock == sample_points[0]
    samples << (x_reg * sample_points.shift)
  end

  break if sample_points.empty?
end

puts samples.sum