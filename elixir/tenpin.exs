defmodule Bowling.Tenpin do
  # strike
  def score([10, bonus1, bonus2 | tail]) do
    10 + bonus1 + bonus2 + score([bonus1, bonus2 | tail])
  end

  # spare
  def score([spare1, spare2, bonus | tail]) when spare1 + spare2 == 10 do
    spare1 + spare2 + bonus + score([bonus | tail])
  end

  # open frame
  def score([roll1, roll2 | tail]) when roll1 + roll2 < 10 do
    roll1 + roll2 + score(tail)
  end

  # fallthrough
  def score([_ | _]), do: 0 # incomplete/unscoreable frame
  def score([]), do: 0 # no rolls left
end

ExUnit.start()

defmodule TenpinTest do
  use ExUnit.Case
  alias Bowling.Tenpin, as: Tenpin

  test "initial score" do
    assert Tenpin.score([]) == 0
  end

  test "complete open frame" do
    assert Tenpin.score([1,1]) == 2
  end

  test "multiple complete open frames" do
    assert Tenpin.score([1,1,1,1,1,1,1,1,1,1]) == 10
  end

  test "incomplete open frame" do
    assert Tenpin.score([1]) == 0
  end

  test "multiple open frames with last incomplete" do
    assert Tenpin.score([1,1,1,1,1]) == 4
  end

  test "all gutter balls" do
    rolls = [0,0,0,0,0,0,0,0,0,0]
    assert Tenpin.score(rolls) == 0
  end

  test "complete strike followed by complete open frame" do
    assert Tenpin.score([10,1,1]) == 14
  end

  test "complete strike followed by incomplete spare" do
    assert Tenpin.score([10,5,5]) == 20
  end

  test "complete strike followed by complete spare" do
    assert Tenpin.score([10,5,5,1]) == 31
  end

  test "incomplete strike, no bonus rolls" do
    assert Tenpin.score([10]) == 0
  end

  test "incomplete strike, one bonus roll" do
    assert Tenpin.score([10,1]) == 0
  end

  test "perfect game" do
    rolls = [10,10,10,10,10,10,10,10,10,10,10,10]
    assert Tenpin.score(rolls) == 300
  end

  test "complete spare" do
    assert Tenpin.score([3,7,4]) == 14
  end

  test "complete spare followed by complete open frame" do
    assert Tenpin.score([3,7,4,1]) == 19
  end

  test "complete spare followed by strike with no bonus rolls" do
    assert Tenpin.score([3,7,10]) == 20
  end

  test "complete spare followed by strike with one bonus roll" do
    assert Tenpin.score([3,7,10,1]) == 20
  end

  test "all fives" do
    rolls = [5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5]
    assert Tenpin.score(rolls) == 150
  end
end
