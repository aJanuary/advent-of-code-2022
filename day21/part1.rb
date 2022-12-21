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

expressions = Hash[ARGF.each_line.map(&:chomp).map do |line|
  name, expr_str = line.split(': ')
  expr_parts = expr_str.split(' ')
  if expr_parts.size == 1
    expr = NumberExpression.new(expr_parts[0].to_i)
  else
    expr = FormulaExpression.new(*expr_parts)
  end
  [name, expr]
end]

puts expressions['root'].evaluate(expressions)