#!/usr/bin/env ruby

HEADER_SIZE = 4

header_start = ARGF.each_char
  .each_cons(HEADER_SIZE)
  .each_with_index
  .find {|chunk, index| chunk.uniq.length == HEADER_SIZE}
  .last
header_offset = header_start + HEADER_SIZE
puts header_offset