defmodule Dmage.RangeRunnerTest do
  use ExUnit.Case

  alias Dmage.Range.Calculator
  alias Dmage.Range.Runner

  defp includes({t1, t2}, {min1, max1}, {min2, max2}) do
    includes(t1, min1, max1) and includes(t2, min2, max2)
  end
  defp includes({t1, t2}, min, max) do
    includes(t1, min, max) and includes(t2, min, max)
  end
  defp includes(value, min, max) do
    value >= min and value <= max and is_whole value
  end

  defp between({t1, t2}, {min1, max1}, {min2, max2}) do
    between(t1, min1, max1) and between(t2, min2, max2)
  end
  defp between({t1, t2}, min, max) do
    between(t1, min, max) and between(t2, min, max)
  end
  defp between(value, min, max) do
    value > min and value < max and is_whole value
  end

  defp is_whole(n) do
    n == trunc n
  end

  defp summs(t, n) when is_tuple(t) do
    n == Tuple.sum(t)
  end

  test "locals" do
    assert includes(3, 2, 4)
    assert includes(2, 2, 4)

    assert between(3, 2, 4)
    refute between(2, 2, 4)

    assert includes({1, 2}, 0, 5)
    assert includes({1, 2}, 0, 5)

    assert includes({1, 2}, {0, 3}, {1, 2})
    refute includes({1, 2}, {0, 0}, {1, 4})

    assert between({1, 2}, 0, 5)
    assert between({1, 2}, 0, 5)

    assert between({1, 2}, {0, 5}, {0, 10})
    refute between({1, 2}, {2, 5}, {1, 2})

    assert is_whole(1.0)
    refute is_whole(1.2)

    assert summs {1, 2}, 3
    refute summs {1, 2}, 4
  end


  test "run hits" do
    assert includes Runner.hits(1, 1), 0, 1
    assert includes Runner.hits(1, 3), 0, 1

    assert includes Runner.hits(6, 1), 0, 6
    assert includes Runner.hits(6, 2), 0, 6
    assert between Runner.hits(12, 1), 0, 12

    #min/max
    assert 6 == Runner.hits(6, 6)
    assert 0 == Runner.hits(0, 6)
    assert 0 == Runner.hits(1, 0)

    #illegal
    assert {:error, "dice cannot be negative"} == Runner.hits(-1, 1)
    assert {:error, "eyes cannot be negative"} == Runner.hits(1, -1)
    assert {:error, "eyes cannot excced 6"} == Runner.hits(1, 7)
  end



  #rerolls not accounted for
  test "attack dice" do
    assert includes Runner.attacks(1, 3), 0, 1
    assert includes Runner.attacks(1, 4), 0, 1

    assert includes Runner.attacks(4, 3), 0, 4
    assert includes Runner.attacks(4, 4), 0, 4

    #min/max
    assert {0.0, 0.0} == Runner.attacks(0, 6)
    assert includes Runner.attacks(6, 6), {0, 0}, {0, 6}
    assert includes Runner.attacks(6, 2), 0, 6

    #illegal
    assert {:error, "dice cannot be negative"} == Runner.attacks(-1, 1)
    assert {:error, "skill cannot be less than 2"} == Runner.attacks(1, 1)
    assert {:error, "skill cannot excced 6"} == Runner.attacks(1, 7)
  end

  #rerolls not accounted for
  test "probable saves" do
    dice = 3

    #normal
    assert {0.5, 0.5} == Calculator.saves(dice, 5, 0)
    assert {1.0, 0.5} == Calculator.saves(dice, 4, 0)
    assert {1.5, 0.5} == Calculator.saves(dice, 3, 0)

    #min/max
    assert {2.5, 0.5} == Calculator.saves(dice, 1, 0)
    assert {0.0, 0.5} == Calculator.saves(dice, 6, 0)

    #variation
    assert {2/3, 1/3} == Calculator.saves(2, 4, 0)
    assert {1/3, 1/6} == Calculator.saves(1, 4, 0)
    assert {0.0, 0.0} == Calculator.saves(0, 4, 0)

    #retained
    assert {2.0, 1/3} == Calculator.saves(dice, 3, 1)
    assert {2.5, 1/6} == Calculator.saves(dice, 3, 2)
    assert {3.0, 0.0} == Calculator.saves(dice, 3, 3)

    #illegal
    assert {:error, "dice cannot be negative"} == Calculator.saves(-1, 6, 0)
    assert {:error, "save cannot be less than 1"} == Calculator.saves(dice, 0, 0)
    assert {:error, "save cannot be greater than 6"} == Calculator.saves(dice, 7, 0)
    assert {:error, "retained cannot be greater than 3"} == Calculator.saves(dice, 4, 4)
  end

  test "resolve probable" do
    assert {3.0, 0.67} == Calculator.resolve({2.0, 2/3}, {1.0, 0.5}, {3, 4})
    assert {4.5, 0.0} == Calculator.resolve({2.5, 1}, {1.0, 1}, {3, 4})
    assert {2.0, 7.5} == Calculator.resolve({2, 2}, {1.0, 0.5}, {2, 5})
    assert {10.0, 0.0} == Calculator.resolve({6, 0}, {1.0, 0.5}, {2, 5})
  end

  #doubling up on crits not implemented
  test "probable in open" do
    assert 5.17 == Calculator.probable_damage_in_open([4, 3, 3, 4, 5])
    assert 0.0 == Calculator.probable_damage_in_open([3, 4, 2, 3, 4])
    assert 14.5 == Calculator.probable_damage_in_open([5, 3, 5, 6, 6])
    assert 0.0 == Calculator.probable_damage_in_open([3, 5, 2, 3, 3])
  end

  #doubling up on crits not implemented
  test "probable in cover" do
    assert 3.33 == Calculator.probable_damage_in_cover([4, 3, 3, 4, 5])
    assert 0.5 == Calculator.probable_damage_in_cover([3, 4, 2, 3, 4])
    assert 10.5 == Calculator.probable_damage_in_cover([5, 3, 5, 6, 6])
    assert 0.5 == Calculator.probable_damage_in_cover([3, 5, 2, 3, 3])
  end
end
