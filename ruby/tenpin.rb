require "forwardable"

module Bowling
  class Tenpin
    attr_reader :frames

    def initialize
      @frames = Array.new(10) { Frame.new }
    end

    def roll(pinfall)
      frames.detect { |f| f.handles_normal_roll? }.roll(pinfall)
    end

    def score
      frames.sum(&:score)
    end
  end

  class Frame
    extend Forwardable
    def_delegators :@state, :score, :handles_normal_roll?

    attr_reader :rolls
    attr_accessor :state

    def initialize
      @rolls = []
      @state = FrameState.initial_state(self)
    end

    def roll(pinfall)
      rolls << pinfall
      state.transition!
    end

    def method_missing(method_name, *args, &block)
      state.send(method_name, *args, &block)
    end
  end

  class FrameState
    def self.initial_state(frame)
      PendingState.new(frame)
    end

    attr_reader :frame

    def initialize(frame)
      @frame = frame
    end

    def transition!
      frame.state = if frame.rolls.size == 2
                      CompleteState.new(frame)
                    else
                      frame.state
                    end
    end
  end

  class PendingState < FrameState
    def score
      0
    end

    def complete?
      false
    end

    def handles_normal_roll?
      true
    end
  end

  class CompleteState < FrameState
    def score
      frame.rolls.sum
    end

    def complete?
      true
    end

    def handles_normal_roll?
      false
    end
  end
end

require "minitest/autorun"

class TestTenpin < Minitest::Test
  def setup
    @game = Bowling::Tenpin.new
  end

  def test_initial_score
    assert_equal @game.score, 0
  end

  def test_incomplete_open_frame
    @game.roll(1)
    assert_equal 0, @game.score
  end

  def test_complete_open_frame
    2.times { @game.roll(1) }
    puts @game.frames.first.state
    assert_equal 2, @game.score
  end
end

class TestFrame < Minitest::Test
  def setup
    @frame = Bowling::Frame.new
  end

  def test_incomplete_open_frame
    @frame.roll(1)
    assert_equal 0, @frame.score
  end

  def test_complete_open_frame
    2.times { @frame.roll(1) }
    assert_equal 2, @frame.score
  end
end
