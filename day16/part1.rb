#!/usr/bin/env ruby

require 'set'

MAX_TIME = 30
Valve = Struct.new(:name, :flow_rate, :tunnels)

map = Hash[ARGF.each_line.map do |line|
  name, flow_rate_str, tunnels_str = line.scan(/Valve ([^ ]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/)[0]
  flow_rate = flow_rate_str.to_i
  tunnels = tunnels_str.split(', ')
  [name, Valve.new(name, flow_rate, tunnels)]
end]

def find_shorted_distances(map, start, ends)
  unvisited = map.keys
  dist = Hash.new {|h, k| h[k] = Float::INFINITY}
  dist[start.name] = 0

  until unvisited.empty?
    cur_pos = unvisited.min_by {|u| dist[u]}
    unvisited.delete(cur_pos)

    neighbours = map[cur_pos].tunnels
    unvisited_neighbours = neighbours.filter {|n| unvisited.include?(n)}
    new_dist = dist[cur_pos] + 1
    unvisited_neighbours.each do |neighbour|
      dist[neighbour] = [new_dist, dist[neighbour]].min
    end
  end

  Hash[ends.select {|valve| valve != start}.map {|valve| [valve.name, dist[valve.name]]}]
end

non_zero_valves = map.values.select {|valve| valve.flow_rate > 0}
interesting_valves = non_zero_valves + [map['AA']]

graph = Hash[interesting_valves.map do |interesting_valve|
  [interesting_valve.name, find_shorted_distances(map, interesting_valve, interesting_valves)]
end]

def calc_pressure_released(map, open_valves)
  open_valves.map {|valve| map[valve].flow_rate}.sum
end

def potential(map, state)
  time_left = MAX_TIME - state[:time]
  state[:pressure_released] + (calc_pressure_released(map, state[:open_valves]) * time_left)
end

cur_states = [
  {
    valve: 'AA',
    pressure_released: 0,
    open_valves: Set.new,
    time: 0
  }
]

until cur_states.all? {|state| state[:time] == MAX_TIME} do
  puts "."
  cur_states = cur_states.flat_map do |state|
    if state[:time] == MAX_TIME
      [state]
    else
      if state[:open_valves].size == non_zero_valves.size
        [{
          valve: state[:valve],
          pressure_released: potential(map, state),
          open_valves: state[:open_valves],
          time: MAX_TIME
        }]
      else
        new_states = graph[state[:valve]].flat_map do |target, time|
          if state[:time] + time > MAX_TIME
            []
          else
            [{
              valve: target,
              pressure_released: state[:pressure_released] + (calc_pressure_released(map, state[:open_valves]) * time),
              open_valves: state[:open_valves],
              time: state[:time] + time
            }]
          end
        end
        if !state[:open_valves].include?(state[:valve])
          new_states << {
            valve: state[:valve],
            pressure_released: state[:pressure_released] + calc_pressure_released(map, state[:open_valves]),
            open_valves: state[:open_valves] + [state[:valve]],
            time: state[:time] + 1
          }
        end
        new_states
      end
    end
  end

  unique_states = Hash.new
  cur_states.each do |state|
    key = [state[:valve], state[:open_valves]]
    if !unique_states.has_key?(key) || potential(map, state) > potential(map, unique_states[key])
      unique_states[key] = state
    end
  end
  cur_states = unique_states.values
end

puts cur_states.max_by {|state| state[:pressure_released]}[:pressure_released]