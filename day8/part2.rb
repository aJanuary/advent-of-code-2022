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

def calc_scenic_score_up(map, x, y)
  idx = (y - 1).downto(0).to_a.index do |check_y|
    map[x, check_y] >= map[x, y]
  end
  idx.nil? ? y : idx + 1
end

def calc_scenic_score_right(map, x, y)
  idx = ((x + 1)...map.width).to_a.index do |check_x|
    map[check_x, y] >= map[x, y]
  end
  idx.nil? ? (map.width - x - 1) : idx + 1
end

def calc_scenic_score_down(map, x, y)
  idx = ((y + 1)...map.height).to_a.index do |check_y|
    map[x, check_y] >= map[x, y]
  end
  idx.nil? ? (map.height - y - 1) : idx + 1
end

def calc_scenic_score_left(map, x, y)
  idx = (x - 1).downto(0).to_a.index do |check_x|
    map[check_x, y] >= map[x, y]
  end
  idx.nil? ? x : idx + 1
end

def calc_scenic_score(map, x, y)
  calc_scenic_score_up(map, x, y) *
    calc_scenic_score_right(map, x, y) *
    calc_scenic_score_down(map, x, y) *
    calc_scenic_score_left(map, x, y)
end

map = Map.new(ARGF.each_line.map {|line| line.chomp.split('').map(&:to_i)})

scores = (0...map.height).map do |y|
  (0...map.width).map do |x|
    calc_scenic_score(map, x, y)
  end
end

puts scores.flatten.max