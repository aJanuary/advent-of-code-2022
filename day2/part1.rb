#!/usr/bin/env ruby

RPS = [:paper, :rock, :scissors]

THEM_TO_RPS = {
  'A' => :rock,
  'B' => :paper,
  'C' => :scissors
}

ME_TO_RPS = {
  'X' => :rock,
  'Y' => :paper,
  'Z' => :scissors
}

SCORE_FOR_PLAYING = {
  :rock => 1,
  :paper => 2,
  :scissors => 3
}

SCORE_FOR_WINNING = {
  :win => 6,
  :draw => 3,
  :lose => 0
}

def play_rps(them, me)
  return :draw if them == me
  return :win if RPS.index(them) == ((RPS.index(me) + 1) % RPS.length)
  :lose
end

def score(them, me)
  SCORE_FOR_PLAYING[me] + SCORE_FOR_WINNING[play_rps(them, me)]
end

strategy = ARGF.each_line.map do |l|
  them, me = l.chomp.split(' ')
  them = THEM_TO_RPS[them]
  me = ME_TO_RPS[me]
  [them, me]
end

scores = strategy.map {|them, me| score(them, me)}
puts scores.sum