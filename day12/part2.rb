#!/usr/bin/env ruby

require 'set'

Position = Struct.new(:x, :y) do
  def +(other)
    Position.new(self.x + other.x, self.y + other.y)
  end
end

Rect = Struct.new(:width, :height) do
  def include?(point)
    (0...self.width).include?(point.x) && (0...self.height).include?(point.y)
  end
end

class Field2D
  attr_reader :bounds

  def initialize(values)
    @values = values
    @bounds = Rect.new(values[0].size, values.size)
  end

  def [](pos)
    @values[pos.y][pos.x]
  end

  def []=(pos, value)
    @values[pos.y][pos.x] = value
  end
end

def parse_map(stream)
  start_pos = []
  end_pos = nil
  heights = stream.each_line.map(&:chomp).each_with_index.map do |line, y|
    line.chars.each_with_index.map do |c, x|
      if ['S', 'a'].include?(c)
        start_pos << Position.new(x, y)
        'a'.ord - 'a'.ord
      elsif c == 'E'
        end_pos = Position.new(x, y)
        'z'.ord - 'a'.ord
      else
        c.ord - 'a'.ord
      end
    end
  end
  [Field2D.new(heights), start_pos, end_pos]
end

def possible_dirs(map, cur_pos)
  [
    Position.new(0, -1),
    Position.new(1,  0),
    Position.new(0,  1),
    Position.new(-1,  0)
  ].flat_map do |dir| 
    new_pos = cur_pos + dir

    if map.bounds.include?(new_pos) && map[cur_pos] - map[new_pos] <= 1
      [dir]
    else
      []
    end
  end
end

map, start_pos, end_pos = parse_map(ARGF)

dist = Field2D.new(map.bounds.height.times.map { [Float::INFINITY] * map.bounds.width })
dist[end_pos] = 0

unvisited = (0...map.bounds.height).flat_map do |y|
  (0...map.bounds.width).map do |x|
    Position.new(x, y)
  end
end

until unvisited.empty?
  cur_pos = unvisited.min_by {|u| dist[u]}
  unvisited.delete(cur_pos)

  dirs = possible_dirs(map, cur_pos)
  neighbours = dirs.map {|dir| cur_pos + dir}
  unvisited_neighbours = neighbours.filter {|n| unvisited.include?(n)}
  new_dist = dist[cur_pos] + 1
  unvisited_neighbours.each do |neighbour|
    dist[neighbour] = [new_dist, dist[neighbour]].min
  end
end

puts start_pos.map {|pos| dist[pos]}.min