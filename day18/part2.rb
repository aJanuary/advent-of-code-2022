#!/usr/bin/env ruby

require 'set'

class Bounds
  attr_reader :min_x, :max_x, :min_y, :max_y, :min_z, :max_z

  def initialize(coordinates)
    @min_x = coordinates.map {|x, y, z| x}.min - 1
    @max_x = coordinates.map {|x, y, z| x}.max + 1
    @min_y = coordinates.map {|x, y, z| y}.min - 1
    @max_y = coordinates.map {|x, y, z| y}.max + 1
    @min_z = coordinates.map {|x, y, z| z}.min - 1
    @max_z = coordinates.map {|x, y, z| z}.max + 1
  end

  def include?(x, y, z)
    x >= @min_x && x <= @max_x && y >= @min_y && y <= @max_y && z >= @min_z && z <= @max_z
  end
end

class Cube
  attr_reader :bounds

  def initialize(bounds)
    # Add 1 because bounds are inclusive
    width = bounds.max_x - bounds.min_x + 1
    height = bounds.max_y - bounds.min_y + 1
    depth = bounds.max_z - bounds.min_z + 1
    @bounds = bounds
    @data = width.times.map { height.times.map { depth.times.map { :unknown } } }
  end

  def [](x, y, z)
    return :outside if !@bounds.include?(x, y, z)
    @data[x - @bounds.min_x][y - @bounds.min_y][z - @bounds.min_z]
  end

  def []=(x, y, z, value)
    @data[x - @bounds.min_x][y - @bounds.min_y][z - @bounds.min_z] = value
  end
end

def flood_fill(cube, x, y, z)
  return unless cube.bounds.include?(x, y, z)
  return unless cube[x, y, z] == :unknown
  cube[x, y, z] = :outside
  flood_fill(cube, x - 1, y, z)
  flood_fill(cube, x + 1, y, z)
  flood_fill(cube, x, y - 1, z)
  flood_fill(cube, x, y + 1, z)
  flood_fill(cube, x, y, z - 1)
  flood_fill(cube, x, y, z + 1)
end

coordinates = ARGF.each_line.map(&:chomp).map {|l| l.split(',').map(&:to_i)}

bounds = Bounds.new(coordinates)
cube = Cube.new(bounds)
coordinates.each do |x, y, z|
  cube[x, y, z] = :rock
end

flood_fill(cube, bounds.min_x, bounds.min_y, bounds.min_z)

surface_area = coordinates.map do |x, y, z|
  [
    [-1,  0,  0],
    [ 1,  0,  0],
    [ 0, -1,  0],
    [ 0,  1,  0],
    [ 0,  0, -1],
    [ 0,  0,  1]
  ].count do |dx, dy, dz|
    cube[x + dx, y + dy, z + dz] == :outside
  end
end

puts surface_area.sum