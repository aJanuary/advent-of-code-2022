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

def is_distress_signal(sensors, candidate_coord)
  return if !COORD_RANGE.include?(candidate_coord.x) || !COORD_RANGE.include?(candidate_coord.y)

  sensors.all? do |sensor|
    taxicab_distance(candidate_coord, sensor.coord) > sensor.scan_distance
  end
end

def find_distress_signal_coords(sensors)
  # Because there is only one possible location, the distress signal can only be
  # just outside the edge of one or more sensors. So rather than check the
  # trillion possible locations, just check the edges of the sensor ranges.
  sensors.each_with_index do |sensor, i|
    coord = Coordinate.new(sensor.coord.x + sensor.scan_distance + 1, sensor.coord.y)

    until coord.x == sensor.coord.x
      coord += Coordinate.new(-1, 1)
      return coord if is_distress_signal(sensors, coord)
    end
    until coord.y == sensor.coord.y
      coord += Coordinate.new(-1, -1)
      return coord if is_distress_signal(sensors, coord)
    end
    until coord.x == sensor.coord.x
      coord += Coordinate.new(1, -1)
      return coord if is_distress_signal(sensors, coord)
    end
    until coord.x == sensor.coord.x + sensor.scan_distance + 1
      coord += Coordinate.new(1, 1)
      return coord if is_distress_signal(sensors, coord)
    end
  end
end

distress_signal_coords = find_distress_signal_coords(sensors)
puts (distress_signal_coords.x * 4000000) + distress_signal_coords.y