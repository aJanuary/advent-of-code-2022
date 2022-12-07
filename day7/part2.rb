#!/usr/bin/env ruby

TOTAL_SIZE = 70000000
REQUIRED_SPACE = 30000000

class Node
  attr_reader :name, :type, :size, :children

  def self.dir(name)
    Node.new(:dir, name, 0)
  end

  def self.file(name, size)
    Node.new(:file, name, size)
  end

  def add_child(child)
    child.parent = self
    @children[child.name] = child

    cur = self
    until cur.nil?
      cur.size += child.size
      cur = cur.parent
    end
  end

  def filter(&predicate)
    (predicate.call(self) ? [self] : []) + @children.values.flat_map {|child| child.filter(&predicate)}
  end

protected
  def initialize(type, name, size)
    @type = type
    @name = name
    @size = size
    @parent = nil
    @children = {}
  end

  attr_accessor :parent
  attr_writer :size
end

def parse_commands_output(command_output)
  # This algorithm assumes we will always ls the parent directory before cding
  # into it
  root = Node.dir('/')
  stack = []

  command_output.each_line.each do |line|
    parts = line.split(' ')
    case parts
      in ['$', 'cd', '..']
        stack.pop()
      in ['$', 'cd', '/']
        stack = [root]
      in ['$', 'cd', name]
        stack << stack.last.children[name]
      in ['dir', name]
        stack[-1].add_child(Node.dir(name))
      in [size_str, name]
        stack[-1].add_child(Node.file(name, size_str.to_i))
    end
  end

  root
end

tree = parse_commands_output(ARGF.read)

free_space = TOTAL_SIZE - tree.size
to_free = REQUIRED_SPACE - free_space

candidates = tree.filter {|item| item.type == :dir and item.size >= to_free}
to_delete = candidates.min_by {|item| item.size}
puts to_delete.size