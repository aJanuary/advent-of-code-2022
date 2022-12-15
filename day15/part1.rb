#!/usr/bin/env ruby

require 'set'

SLICE_Y = 2000000

Coordinate = Struct.new(:x, :y)
Sensor = Struct.new(:coord, :scan_distance)

def taxicab_distance(a, b)
  (a.x - b.x).abs + (a.y - b.y).abs
end

sensors = []
beacons = Set.new

ARGF.each_line.each do |line|
  sensor_x, sensor_y, beacon_x, beacon_y = line.scan(/-?\d+/).map(&:to_i)
  sensor_coord = Coordinate.new(sensor_x, sensor_y)
  beacon_coord = Coordinate.new(beacon_x, beacon_y)
  scan_distance = taxicab_distance(sensor_coord, beacon_coord)
  sensors << Sensor.new(sensor_coord, scan_distance)
  beacons << beacon_coord
end

min_x = sensors.map {|s| s.coord.x - s.scan_distance}.min
max_x = sensors.map {|s| s.coord.x + s.scan_distance}.max

visible = (min_x...max_x).map do |x|
  coord = Coordinate.new(x, SLICE_Y)
  sensors.any? do |sensor|
    taxicab_distance(coord, sensor.coord) <= sensor.scan_distance
  end
end

puts visible.count(true) - beacons.count {|b| b.y == SLICE_Y}