#!/usr/bin/env ruby

class NumberExpression
  def initialize(number)
    @number = number
  end

  def evaluate(expressions)
    @number
  end
end

class FormulaExpression
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @op = op
    @rhs = rhs
  end

  def evaluate(expressions)
    evaluated_lhs = expressions[@lhs].evaluate(expressions)
    evaluated_rhs = expressions[@rhs].evaluate(expressions)
    case @op
      when '+'
        evaluated_lhs + evaluated_rhs
      when '-'
        evaluated_lhs - evaluated_rhs
      when '*'
        evaluated_lhs * evaluated_rhs
      when '/'
        evaluated_lhs / evaluated_rhs
    end
  end
end

class RootExpression
  def initialize(lhs, op, rhs)
    @lhs = lhs
    @rhs = rhs
  end

  def evaluate(expressions)
    evaluated_lhs = expressions[@lhs].evaluate(expressions)
    evaluated_rhs = expressions[@rhs].evaluate(expressions)
    if evaluated_lhs.instance_of? UnknownNumber
      unknown, known = [evaluated_lhs, evaluated_rhs]
    else
      unknown, known = [evaluated_rhs, evaluated_lhs]
    end

    cur = known.value
    unknown.ops.reverse.each do |lhs, rhs|
      if lhs.instance_of? Integer
        case rhs
        when '+'
          cur = cur - lhs
        when '-'
          cur = lhs - cur
        when '*'
          cur = cur / lhs
        when '/'
          raise 'Cannot handle this situation yet'
        end
      else
        case lhs
        when '+'
          cur = cur - rhs
        when '-'
          cur = rhs + cur
        when '*'
          cur = cur / rhs
        when '/'
          cur = rhs * cur
        end
      end
    end

    cur
  end
end

class KnownNumber
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def +(other)
    if other.instance_of? UnknownNumber
      UnknownNumber.new(other.ops + [[@value, '+']])
    else
      KnownNumber.new(@value + other.value)
    end
  end

  def -(other)
    if other.instance_of? UnknownNumber
      UnknownNumber.new(other.ops + [[@value, '-']])
    else
      KnownNumber.new(@value - other.value)
    end
  end

  def /(other)
    if other.instance_of? UnknownNumber
      UnknownNumber.new(other.ops + [[@value, '/']])
    else
      KnownNumber.new(@value / other.value)
    end
  end

  def *(other)
    if other.instance_of? UnknownNumber
      UnknownNumber.new(other.ops + [[@value, '*']])
    else
      KnownNumber.new(@value * other.value)
    end
  end

  def to_s
    @value
  end
end

class UnknownNumber
  attr_reader :ops

  def initialize(ops)
    @ops = ops
  end

  def +(other)
    UnknownNumber.new(@ops + [['+', other.value]])
  end

  def -(other)
    UnknownNumber.new(@ops + [['-', other.value]])
  end

  def /(other)
    UnknownNumber.new(@ops + [['/', other.value]])
  end

  def *(other)
    UnknownNumber.new(@ops + [['*', other.value]])
  end
end

class HumanExpression
  def evaluate(expressions)
    UnknownNumber.new([])
  end
end

expressions = Hash[ARGF.each_line.map(&:chomp).map do |line|
  name, expr_str = line.split(': ')
  expr_parts = expr_str.split(' ')
  if name == 'root'
    expr = RootExpression.new(*expr_parts)
  elsif name == 'humn'
    expr = HumanExpression.new()
  elsif expr_parts.size == 1
    expr = NumberExpression.new(KnownNumber.new(expr_parts[0].to_i))
  else
    expr = FormulaExpression.new(*expr_parts)
  end
  [name, expr]
end]

pp expressions['root'].evaluate(expressions)