defmodule Dmage.RangeRunnerTest do
  use ExUnit.Case

  alias Dmage.Benchmark
  alias Dmage.Range.Runner

  defp includes({t1, t2}, {min1, max1}, {min2, max2}) do
    includes(t1, min1, max1) and includes(t2, min2, max2)
  end
  defp includes({t1, t2}, min, max) do
    includes(t1, min, max) and includes(t2, min, max)
  end
  defp includes(value, min, max) do
    value >= min and value <= max
  end

  defp between({t1, t2}, {min1, max1}, {min2, max2}) do
    between(t1, min1, max1) and between(t2, min2, max2)
  end
  defp between({t1, t2}, min, max) do
    between(t1, min, max) and between(t2, min, max)
  end
  defp between(value, min, max) do
    value > min and value < max
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
    assert includes Runner.hits(12, 1), 0, 12

    #min/max
    assert includes Runner.hits(6, 5), 0, 6
    assert {0, 0} == Runner.hits(0, 6)
    assert {0, 0} == Runner.hits(1, 0)

    #illegal
    assert {:error, "dice cannot be negative"} == Runner.hits(-1, 1)
    assert {:error, "eyes cannot be negative"} == Runner.hits(1, -1)
    assert {:error, "eyes cannot be or excced 6"} == Runner.hits(1, 6)
    assert {:error, "eyes cannot be or excced 6"} == Runner.hits(1, 7)
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

    #total dice
    assert 1..100
    |> Enum.filter(fn _x -> Tuple.sum(Runner.attacks(6, 2)) > 6 end)
    |> Enum.empty?()

    #illegal
    assert {:error, "dice cannot be negative"} == Runner.attacks(-1, 1)
    assert {:error, "skill cannot be less than 2"} == Runner.attacks(1, 1)
    assert {:error, "skill cannot excced 6"} == Runner.attacks(1, 7)
  end

  #rerolls not accounted for
  test "save dice" do
    dice = 3

    #normal
    assert includes Runner.saves(dice, 5, 0), 0, 3
    assert includes Runner.saves(dice, 4, 0), 0, 3
    assert includes Runner.saves(dice, 3, 0), 0, 3

    #min/max
    assert includes Runner.saves(dice, 2, 0), {0, 3}, {0, 3}
    assert includes Runner.saves(dice, 6, 0), {0, 3}, {0, 3}
    assert includes Runner.saves(dice, 6, dice), {3, 3}, {0, 0}

    #retained
    assert includes Runner.saves(dice, dice, 1), {1, 3}, {0, 3}
    assert includes Runner.saves(dice, dice, 2), {2, 3}, {0, 3}
    assert includes Runner.saves(dice, dice, dice), {3, 3}, {0, 0}

    #illegal
    assert {:error, "dice cannot be negative"} == Runner.saves(-1, 6, 0)
    assert {:error, "save cannot be less than 2"} == Runner.saves(dice, 1, 0)
    assert {:error, "save cannot be greater than 6"} == Runner.saves(dice, 7, 0)
    assert {:error, "retained cannot be greater than 3"} == Runner.saves(dice, 4, 4)
  end

  test "resolve probable" do
    #normal
    #whole
    assert {6.0, 4.0} == Runner.resolve({2, 1}, {0, 0}, {3, 4})
    assert {3.0, 4.0} == Runner.resolve({2, 1}, {1, 0}, {3, 4})
    assert {3.0, 0.0} == Runner.resolve({2, 1}, {1, 1}, {3, 4})
    assert {0.0, 0.0} == Runner.resolve({2, 1}, {2, 1}, {3, 4})
    assert {0.0, 0.0} == Runner.resolve({2, 1}, {3, 1}, {3, 4})
    assert {0.0, 0.0} == Runner.resolve({2, 1}, {3, 2}, {3, 4})
    assert {0.0, 0.0} == Runner.resolve({0, 0}, {3, 2}, {3, 4})
    assert {2.0, 5.0} == Runner.resolve({2, 2}, {1, 1}, {2, 5})
    assert {10.0, 0.0} == Runner.resolve({6, 0}, {1, 0}, {2, 5})

    #crit
    assert {0.0, 0.0} == Runner.resolve({0, 1}, {2, 0}, {3, 5})
    assert {3.0, 0.0} == Runner.resolve({1, 1}, {2, 0}, {3, 5})
    assert {3.0, 0.0} == Runner.resolve({1, 1}, {2, 0}, {3, 4})

    assert {0.0, 4.0} == Runner.resolve({2, 1}, {2, 0}, {3, 4})
    assert {4.0, 0.0} == Runner.resolve({2, 1}, {2, 0}, {2, 4})

    assert {2.0, 0.0} == Runner.resolve({1, 2}, {4, 0}, {2, 4})
  end

  #doubling up on crits not implemented
  test "average in open" do
    Benchmark.measure(fn -> Runner.damage_in_open([4, 3, 3, 4, 5], 1_000) end)
    |> IO.inspect(label: "average 1000 run time")
    Benchmark.measure(fn -> Runner.damage_in_open([4, 3, 3, 4, 5], 10_000) end)
    |> IO.inspect(label: "average 10000 run time")

    assert between Runner.damage_in_open([4, 3, 3, 4, 4], 10_000), 5.5, 6 #5.67
    assert between Runner.damage_in_open([3, 4, 2, 3, 4], 10_000), 1.5, 2 #1.89
    assert between Runner.damage_in_open([5, 3, 5, 6, 6], 10_000), 17, 18 #17.5
    assert between Runner.damage_in_open([3, 5, 2, 3, 3], 10_000), 0.8, 1 #0.97
  end
end
