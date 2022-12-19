#!/usr/bin/env ruby

Blueprint = Struct.new(:id, :robot_costs)

class Resources
  attr_reader :robots, :minerals

  def initialize(robots=nil, minerals=nil)
    if robots.nil?
      @robots = Hash.new {|h, k| h[k] = 0}
    else
      @robots = robots
    end

    if minerals.nil?
      @minerals = Hash.new {|h, k| h[k] = 0}
    else
      @minerals = minerals
    end
  end

  def dup
    Resources.new(@robots.dup, @minerals.dup)
  end
end

def parse_blueprint(line)
  id_part, robots_part = line.split(': ')
  id = id_part.scan(/Blueprint (\d+)/)[0][0].to_i

  robot_costs = Hash[robots_part.split('. ').map do |robot_part|
    type_part, costs_part = robot_part.split('costs')
    type = type_part.scan(/Each (\w+) robot/)[0][0].to_sym
    costs = costs_part.split(' and ').flat_map do |cost_part|
      cost_part.scan(/(\d+) (\w+)/).map do |cost, mineral|
        [cost.to_i, mineral.to_sym]
      end
    end
    [type, costs]
  end]

  Blueprint.new(id, robot_costs)
end

def get_choices(blueprint, resources)
  choices = blueprint.robot_costs.select do |type, cost|
    cost.all? do |cost, mineral|
      (resources.minerals[mineral] || 0) >= cost
    end
  end.map {|type, cost| type}
  return [:geode] if choices.include?(:geode)
  choices + [:nothing]
end

blueprints = ARGF.each_line.map {|line| parse_blueprint(line)}

starting_resources = Resources.new()
starting_resources.robots[:ore] = 1

max_geodes = blueprints[0...3].map do |blueprint|
  leaves = [starting_resources]

  32.times do |i|
    leaves = leaves.flat_map do |resources|
      choices = get_choices(blueprint, resources)

      choices.map do |choice|
        new_resources = resources.dup

        resources.robots.each do |type, quantity|
          new_resources.minerals[type] += quantity
        end

        if choice != :nothing
          new_resources.robots[choice] += 1
          blueprint.robot_costs[choice].each do |cost, type|
            new_resources.minerals[type] -= cost
          end
        end

        new_resources
      end
    end

    max_geode_robots = leaves.map {|resources| resources.robots[:geode]}.max
    leaves.delete_if do |a|
      a.robots[:geode] != max_geode_robots || leaves.any? do |b|
        !a.equal?(b) && a.minerals.all? do |type, quantity|
          quantity <= b.minerals[type]
        end && a.robots.all? do |type, quantity|
          quantity <= b.robots[type]
        end
      end
    end
  end

  max_geodes = leaves.map {|resources| resources.minerals[:geode]}.max
  max_geodes
end

puts max_geodes.inject(:*)