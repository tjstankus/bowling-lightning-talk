require "forwardable"

module Bowling
  class Tenpin
    attr_reader :frames

    def initialize
      @frames = Array.new(10) { Frame.new }
    end

    def roll(pinfall)
      frames_handling_roll.each { |f| f.roll(pinfall) }
    end

    def score
      frames.sum(&:score)
    end

    private

    def frames_handling_roll
      Array[frame_handling_normal_roll] + frames_handling_bonus_roll
    end

    def frame_handling_normal_roll
      frames.detect(&:handles_normal_roll?)
    end

    def frames_handling_bonus_roll
      frames.select(&:handles_bonus_roll?)
    end
  end

  class Frame
    extend Forwardable
    def_delegators :@state,
      :score,
      :handles_normal_roll?,
      :handles_bonus_roll?

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

    def strike?
      rolls.first == 10
    end

    def spare?
      !strike? && rolls.take(2).sum == 10
    end

    def open?
      !strike? && !spare?
    end

    def complete?
      ((strike? || spare?) && rolls.length == 3) || (open? && rolls.length == 2)
    end

    def incomplete?
      !complete?
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
      frame.state = [BonusState, CompleteState, PendingState].detect do |klass|
        klass.state_for?(frame)
      end.new(frame)
    end
  end

  class PendingState < FrameState
    def self.state_for?(frame)
      frame.incomplete?
    end

    def score
      0
    end

    def complete?
      false
    end

    def handles_normal_roll?
      true
    end

    def handles_bonus_roll?
      false
    end
  end

  class BonusState < FrameState
    def self.state_for?(frame)
      (frame.strike? || frame.spare?) && frame.incomplete?
    end

    def score
      0
    end

    def handles_normal_roll?
      false
    end

    def handles_bonus_roll?
      true
    end
  end

  class CompleteState < FrameState
    def self.state_for?(frame)
      frame.complete?
    end

    def score
      frame.rolls.sum
    end

    def complete?
      true
    end

    def handles_normal_roll?
      false
    end

    def handles_bonus_roll?
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

  def test_complete_open_frame
    2.times { @game.roll(1) }
    assert_equal 2, @game.score
  end

  def test_multiple_complete_open_frames
    10.times { @game.roll(1) }
    assert_equal 10, @game.score
  end

  def test_incomplete_open_frame
    @game.roll(1)
    assert_equal 0, @game.score
  end

  def test_multiple_open_frames_with_last_incomplete
    5.times { @game.roll(1) }
    assert_equal 4, @game.score
  end

  def test_all_gutter_balls
    20.times { @game.roll(0) }
    assert_equal 0, @game.score
  end

  def test_complete_strike_followed_by_complete_open_frame
    [10,1,1].each { |pinfall| @game.roll(pinfall) }
    assert_equal 14, @game.score
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

  def test_strike
    @frame.roll(10)
    assert @frame.strike?
  end

  def test_spare
    2.times { @frame.roll(5) }
    assert @frame.spare?
  end

  def test_open
    2.times { @frame.roll(1) }
    assert @frame.open?
  end

  def test_complete_strike
    [10,1,1].each { |pinfall| @frame.roll(pinfall) }
    assert @frame.complete?
  end

  def test_complete_spare
    [5,5,1].each { |pinfall| @frame.roll(pinfall) }
    assert @frame.complete?
  end

  def test_complete_open
    2.times { @frame.roll(1) }
    assert @frame.complete?
  end

  def test_incomplete_strike
    [10,1].each { |pinfall| @frame.roll(pinfall) }
    assert @frame.incomplete?
  end

  def test_incomplete_spare
    [8,2].each { |pinfall| @frame.roll(pinfall) }
    assert @frame.incomplete?
 end

  def test_incomplete_open
    @frame.roll(9)
    assert @frame.incomplete?
  end
end
