ExUnit.start()

defmodule TenpinTest do
  Code.require_file "tenpin.exs", __DIR__

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
