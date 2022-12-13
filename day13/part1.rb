#!/usr/bin/env ruby

def expect(actual, expected)
  raise "Expected #{expected} but got #{actual}" unless actual == expected
end

def parse_value(chars)
  if chars[0] == '['
    parse_list(chars)
  else
    digits = []
    while chars[0] =~ /[0-9]/
      digits << chars.shift
    end
    digits.join('').to_i
  end
end

def parse_list(chars)
  list = []
  expect(chars.shift, '[')
  while chars[0] != ']'
    list << parse_value(chars)
    if chars[0] != ']'
      expect(chars.shift, ',')
    end
  end
  expect(chars.shift, ']')
  list
end

def compare_value(a, b)
  if a.nil? && !b.nil?
    # Left run out of items first
    -1
  elsif !a.nil? && b.nil?
    # Right run out of items first
    1
  elsif a.is_a?(Integer) && b.is_a?(Integer)
    a <=> b
  elsif a.is_a?(Array) && b.is_a?(Array)
    compare_list(a, b)
  elsif a.is_a?(Integer) && b.is_a?(Array)
    compare_list([a], b)
  elsif a.is_a?(Array) && b.is_a?(Integer)
    compare_list(a, [b])
  end
end

def compare_list(a, b)
  # If a is shorter than b, pad the end with nils so we don't truncate b when
  # ziping together.
  a = a + [nil] * (b.length - a.length) if b.length > a.length
  a.zip(b).each do |x, y|
    res = compare_value(x, y)
    return res if res != 0
  end
  0
end

packets = ARGF.each_line.each_slice(3).map {|l| l[0..1]}.map do |pair|
  # Normally, I would just use JSON.parse here because the formats happen to be
  # the same. However, it was a bit of fun to implement the parser manually.
  pair.map {|l| parse_list(l.chomp.chars)}
end

in_correct_order = packets.map {|a, b| compare_list(a, b)}
indices = in_correct_order.each_index.select {|i| in_correct_order[i] == -1}.map {|i| i + 1}
puts indices.sum