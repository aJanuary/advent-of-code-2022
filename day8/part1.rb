#!/usr/bin/env ruby

class Map
  attr_reader :width, :height

  def initialize(map)
    @map = map
    @width = map[0].size
    @height = map.size
  end

  def [](x, y)
    @map[y][x]
  end
end

def is_visible_up(map, x, y)
  (0...y).all? do |check_y|
    map[x, check_y] < map[x, y]
  end
end

def is_visible_right(map, x, y)
  ((x + 1)...map.width).all? do |check_x|
    map[check_x, y] < map[x, y]
  end
end

def is_visible_down(map, x, y)
  ((y + 1)...map.height).all? do |check_y|
    map[x, check_y] < map[x, y]
  end
end

def is_visible_left(map, x, y)
  (0...x).all? do |check_x|
    map[check_x, y] < map[x, y]
  end
end

def is_visible(map, x, y)
  is_visible_up(map, x, y) ||
    is_visible_right(map, x, y) ||
    is_visible_down(map, x, y) ||
    is_visible_left(map, x, y)
end

map = Map.new(ARGF.each_line.map {|line| line.chomp.split('').map(&:to_i)})

visibility = (0...map.height).map do |y|
  (0...map.width).map do |x|
    is_visible(map, x, y)
  end
end

puts visibility.flatten.count(true)