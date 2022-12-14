#!/usr/bin/env ruby

require 'set'

Coordinate = Struct.new(:x, :y) do
  def +(other)
    Coordinate.new(x + other.x, y + other.y)
  end
end

class Map
  def initialize(points)
    @points = Set.new(points)
    @floor_y = points.max_by(&:y).y + 2
  end

  def include?(point)
    point.y == @floor_y || @points.include?(point)
  end
end

def parse_scan(stream)
  Map.new(stream.each_line.map(&:chomp).flat_map do |line|
    pairs = line.split(' -> ').map do |coords|
      Coordinate.new(*coords.split(',').map(&:to_i))
    end
    pairs.each_cons(2).flat_map do |start_coord, end_coord|
      if start_coord.x == end_coord.x
        start_y = [start_coord.y, end_coord.y].min
        end_y = [start_coord.y, end_coord.y].max
        (start_y .. end_y).map do |y|
          Coordinate.new(start_coord.x, y)
        end
      else
        start_x = [start_coord.x, end_coord.x].min
        end_x = [start_coord.x, end_coord.x].max
        (start_x .. end_x).map do |x|
          Coordinate.new(x, start_coord.y)
        end
      end
    end
  end)
end

def add_sand(map, sand, sand_coord)
  [
    Coordinate.new(0, 1),
    Coordinate.new(-1, 1),
    Coordinate.new(1, 1)
  ].each do |drop_delta|
    potential_sand_coord = sand_coord + drop_delta
    if !map.include?(potential_sand_coord) && !sand.include?(potential_sand_coord)
      return add_sand(map, sand, potential_sand_coord)
    end
  end
  
  sand_coord
end

SOURCE = Coordinate.new(500, 0)

map = parse_scan(ARGF)

sand = Set.new
loop do
  sand_coord = add_sand(map, sand, SOURCE)
  sand << sand_coord
  break if sand_coord == SOURCE
end

puts sand.size