#!/usr/bin/env ruby

require 'set'

def priority(item)
  if ('a'..'z').include?(item)
    item.ord - 'a'.ord + 1
  else
    item.ord - 'A'.ord + 27
  end
end

rucksacks = ARGF.each_line.map(&:chomp).map do |line|
  line.chars.each_slice(line.length / 2).to_a
end

misplaced = rucksacks.map do |left, right|
  Set.new(left).intersection(Set.new(right)).first
end

priorities = misplaced.map {|item| priority(item)}
puts priorities.sum