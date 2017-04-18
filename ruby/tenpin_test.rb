require_relative "tenpin"
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
    assert_kind_of Bowling::CompleteState, @frame.state
  end

  def test_complete_spare
    [5,5,1].each { |pinfall| @frame.roll(pinfall) }
    assert_kind_of Bowling::CompleteState, @frame.state
  end

  def test_complete_open
    2.times { @frame.roll(1) }
    assert_kind_of Bowling::CompleteState, @frame.state
  end

  def test_incomplete_strike
    [10,1].each { |pinfall| @frame.roll(pinfall) }
    assert_kind_of Bowling::BonusState, @frame.state
  end

  def test_incomplete_spare
    [8,2].each { |pinfall| @frame.roll(pinfall) }
    assert_kind_of Bowling::BonusState, @frame.state
 end

  def test_incomplete_open
    @frame.roll(9)
    assert_kind_of Bowling::PendingState, @frame.state
  end
end
