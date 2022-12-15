#!/usr/bin/env ruby

require 'set'

COORD_RANGE = (0..4000000)

Coordinate = Struct.new(:x, :y) do
  def +(other)
    Coordinate.new(x + other.x, y + other.y)
  end
end

Sensor = Struct.new(:coord, :scan_distance)

def taxicab_distance(a, b)
  (a.x - b.x).abs + (a.y - b.y).abs
end

sensors = ARGF.each_line.map do |line|
  sensor_x, sensor_y, beacon_x, beacon_y = line.scan(/-?\d+/).map(&:to_i)
  sensor_coord = Coordinate.new(sensor_x, sensor_y)
  beacon_coord = Coordinate.new(beacon_x, beacon_y)
  scan_distance = taxicab_distance(sensor_coord, beacon_coord)
  Sensor.new(sensor_coord, scan_distance)
end

# Because we know there is only one spot for the beacon, we know it must be
# surrounded on all sides by the edge of a sensor's range. If one side wasn't,
# then that would leave another open spot that the beacon could be in.
# Characterize the edges of the sensor range as lines defined as mx + c.
# Positive edges have m=1, negative edges have m=-1. c is the intersection with
# the y axis.
# The beacon must be at the intersection of the lines where two or more positive
# edges overlap, and two or more negative edges overlap.
# So start by finding the lines, then filter out to just the ones that overlap.
# Then look at the combination of all possible positive and negative edges, and
# find their intersection points. This forms our pool of candidates.
# We can then look at each candidate and find the one that is not reachable by
# any sensor.
positive_edges = sensors.flat_map do |sensor|
  [
    sensor.coord.y - (sensor.coord.x - sensor.scan_distance - 1),
    sensor.coord.y - (sensor.coord.x + sensor.scan_distance + 1),
  ]
end

negative_edges = sensors.flat_map do |sensor|
  [
    sensor.coord.y + (sensor.coord.x + sensor.scan_distance + 1),
    sensor.coord.y + (sensor.coord.x - sensor.scan_distance - 1),
  ]
end

overlapping_positive_edges = positive_edges.group_by {|x| x}.select {|k, v| v.length > 1}.map {|k, v| k}
overlapping_negative_edges = negative_edges.group_by {|x| x}.select {|k, v| v.length > 1}.map {|k, v| k}

candidates = overlapping_positive_edges.product(overlapping_negative_edges).flat_map do |positive_edge, negative_edge|
  x_intersection = (negative_edge - positive_edge) / 2
  y_intersection = x_intersection + positive_edge
  if COORD_RANGE.include?(x_intersection) && COORD_RANGE.include?(y_intersection)
    [Coordinate.new(x_intersection, y_intersection)]
  else
    []
  end
end

beacon_coord = candidates.find do |coord|
  sensors.all? do |sensor|
    taxicab_distance(coord, sensor.coord) > sensor.scan_distance
  end
end

tuning_freq = beacon_coord.x * 4000000 + beacon_coord.y
puts tuning_freq