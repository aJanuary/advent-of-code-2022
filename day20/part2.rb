#!/usr/bin/env ruby

DECRYPTION_KEY = 811589153
NUM_MIXES = 10

list = ARGF.each_line.map(&:chomp).map(&:to_i)

multiplied = list.map {|i| i * DECRYPTION_KEY}
annotated = multiplied.each_with_index.to_a

NUM_MIXES.times do
  (0...annotated.size).each do |orig_index|
    index = annotated.index {|a| a.last == orig_index}
    a = annotated.delete_at(index)
    new_index = (index + a.first) % annotated.size
    annotated.insert(new_index, a)
  end
end

zero_index = annotated.index {|a| a.first == 0}
coords = [1_000, 2_000, 3_000].map do |offset|
  annotated[(zero_index + offset) % annotated.size].first
end

puts coords.sum