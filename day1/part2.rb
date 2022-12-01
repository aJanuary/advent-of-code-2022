#!/usr/bin/env ruby

# This takes advantage of two things:
#  1) "".to_i will return 0
#  2) We are summing the calories for each elf, and 0 is the identity for sum
packs = ARGF.each_line.map(&:chomp).slice_when {|s| s == ''}.map {|a| a.map(&:to_i)}
total_calories_per_pack = packs.map(&:sum)
calories_in_top3 = total_calories_per_pack.max(3)
total_calories_in_top3 = calories_in_top3.sum
puts total_calories_in_top3