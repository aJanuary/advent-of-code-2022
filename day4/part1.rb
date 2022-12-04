#!/usr/bin/env ruby

assignments = ARGF.each_line.map(&:chomp).map do |line|
  line.split(',').map do |range_str|
    start_str, end_str = range_str.split('-')
    (start_str.to_i..end_str.to_i)  
  end
end

covers = assignments.map {|a, b| a.cover?(b) || b.cover?(a)}
puts covers.count(true)