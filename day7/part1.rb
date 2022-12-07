#!/usr/bin/env ruby

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

def parse_directory_tree(command_output)
  # This algorithm assumes we will always ls the parent directory before cding
  # into it
  root = Node.dir('/')
  stack = []
  in_ls = false

  command_output.each_line.each do |line|
    parts = line.split(' ')
    if parts[0] == '$'
      if parts[1] == 'cd'
        if parts[2] == '..'
          stack.pop()
        elsif parts[2] == '/'
          stack = [root]
        else
          dir = stack[-1].children[parts[2]]
          stack << dir
        end
      elsif parts[1] == 'ls'
        in_ls = true
      else
        raise "unknown command #{parts[1]}"
      end
    else
      raise "unexpected command output" if !in_ls

      name = parts[1]
      if parts[0] == 'dir'
        stack[-1].add_child(Node.dir(name))
      else
        size = parts[0].to_i
        stack[-1].add_child(Node.file(name, size))
      end
    end
  end

  root
end

tree = parse_directory_tree(ARGF.read)

small_dirs = tree.filter {|item| item.type == :dir and item.size <= 100000}
puts small_dirs.map {|dir| dir.size}.sum