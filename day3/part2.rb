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
  line.chars
end

groups = rucksacks.each_slice(3)

badges = groups.map do |group|
  unique_items = group.map {|rucksack| Set.new(rucksack)}
  unique_items.reduce(&:intersection).first
end

priorities = badges.map {|item| priority(item)}
puts priorities.sum