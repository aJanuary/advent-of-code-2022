#!/usr/bin/env ruby

RPS = [:paper, :rock, :scissors]

DECODE_RPS = {
  'A' => :rock,
  'B' => :paper,
  'C' => :scissors
}

DECODE_WDL = {
  'X' => :lose,
  'Y' => :draw,
  'Z' => :win
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

def calculate_play(them, wdl)
  return RPS[(RPS.index(them) - 1) % RPS.length] if wdl == :win
  return RPS[(RPS.index(them) + 1) % RPS.length] if wdl == :lose
  them
end

def score(them, wdl)
  me = calculate_play(them, wdl)
  SCORE_FOR_PLAYING[me] + SCORE_FOR_WINNING[wdl]
end

strategy = ARGF.each_line.map do |l|
  them, wdl = l.chomp.split(' ')
  them = DECODE_RPS[them]
  wdl = DECODE_WDL[wdl]
  [them, wdl]
end

scores = strategy.map {|them, wdl| score(them, wdl)}
puts scores.sum