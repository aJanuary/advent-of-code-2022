#!/usr/bin/env ruby

list = ARGF.each_line.map(&:chomp).map(&:to_i)

annotated = list.map {|i| [i, true]}

until (index = annotated.index(&:last)).nil?
  a = annotated.delete_at(index)
  new_index = (index + a.first) % annotated.size
  annotated.insert(new_index, [a.first, false])
end

zero_index = annotated.index {|a| a.first == 0}
coords = [1_000, 2_000, 3_000].map do |offset|
  annotated[(zero_index + offset) % annotated.size].first
end

puts coords.sum