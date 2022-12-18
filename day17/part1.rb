#!/usr/bin/env ruby

$debug = true

class Shape
  attr_reader :width, :height

  def initialize(mask)
    @mask = mask.each_line.map(&:strip).map {|line| line.split('').map {|c| c == '#'}}
    @width = @mask[0].size
    @height = @mask.size
  end

  def [](x, y)
    return false if y < 0 || y >= @height || x < 0 || x >= @width
    @mask[y][x]
  end

  def each_cell
    @mask.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        yield(x, y, cell)
      end
    end
  end

  def any_cell?
    @mask.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return true if yield(x, y, cell)
      end
    end
    false
  end
end

class Chamber
  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @cells = height.times.map { width.times.map { false } }
  end

  def [](x, y)
    @cells[y][x]
  end

  def []=(x, y, value)
    @cells[y][x] = value
  end

  def top_row
    @cells.index {|row| row.any?(true)} || @height
  end
end

SHAPES = [
  Shape.new(
    "####"
  ),
  Shape.new(
    ".#.
     ###
     .#."
  ),
  Shape.new(
    "..#
     ..#
     ###"
  ),
  Shape.new(
    "#
     #
     #
     #"
  ),
  Shape.new(
    "##
     ##"
  )
]

def draw(chamber, shape, shape_x, shape_y)
  return unless $debug
  (shape_y...chamber.height).each do |y|
    mask_y = y - shape_y
    print('|')
    (0...chamber.width).each do |x|
      mask_x = x - shape_x
      if chamber[x, y]
        print('#')
      elsif shape[mask_x, mask_y]
        print('@')
      else
        print('.')
      end
    end
    print("|\n")
  end
  puts '+' + ('-' * chamber.width) + '+'
end

def debug(str)
  puts str if $debug
end

def collides?(chamber, shape, shape_x, shape_y)
  return true if shape_x < 0 || (shape_x + shape.width) > chamber.width
  return true if (shape_y + shape.height) > chamber.height
  shape.any_cell? do |x, y, cell|
    cell && chamber[shape_x + x, shape_y + y]
  end
end

SPAWN_GAP = 3
NUM_DROPS = 2022

jets = ARGF.read.chars.map {|c| c == '<' ? -1 : 1}
chamber = Chamber.new(7, NUM_DROPS * SHAPES.map(&:height).sum)

turn = 0
shape_idx = 0
shape = SHAPES[shape_idx % SHAPES.size]
shape_x = 2
shape_y = chamber.top_row - SPAWN_GAP - shape.height

until shape_idx == NUM_DROPS
  direction = jets[turn % jets.size]
  unless collides?(chamber, shape, shape_x + direction, shape_y)
    shape_x += direction
  end

  if collides?(chamber, shape, shape_x, shape_y + 1)
    shape.each_cell do |x, y, cell|
      chamber[shape_x + x, shape_y + y] ||= cell
    end
    shape_idx += 1
    shape = SHAPES[shape_idx % SHAPES.size]
    shape_x = 2
    shape_y = chamber.top_row - SPAWN_GAP - shape.height
  else
    shape_y += 1
  end
  turn += 1
end

puts chamber.height - chamber.top_row