#!/usr/bin/env ruby

coordinates = ARGF.each_line.map(&:chomp).map {|l| l.split(',').map(&:to_i)}

open_faces = coordinates.map { 6 }
(0...coordinates.size).each do |a_index|
  ((a_index + 1)...coordinates.size).each do |b_index|
    if coordinates[a_index].zip(coordinates[b_index]).map {|p| (p[0] - p[1]).abs}.sum == 1
      open_faces[a_index] -= 1
      open_faces[b_index] -= 1
    end
  end
end

puts open_faces.sum