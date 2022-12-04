#!/usr/bin/env ruby

# This seems like a strange omission from the stdlib
class Range
  def overlaps?(other)
    cover?(other.first) || other.cover?(first)
  end
end

assignments = ARGF.each_line.map(&:chomp).map do |line|
  line.split(',').map do |range_str|
    start_str, end_str = range_str.split('-')
    (start_str.to_i..end_str.to_i)  
  end
end

covers = assignments.map {|a, b| a.overlaps?(b)}
puts covers.count(true)