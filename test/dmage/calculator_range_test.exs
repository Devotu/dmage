defmodule Dmage.CalculatorRangeTest do
  use ExUnit.Case

  alias Dmage.Calculator.Range

  test "calculate hits" do
    assert 1/6 == Range.hits(1, 1)
    assert 1/2 == Range.hits(1, 3)

    assert 1 == Range.hits(6, 1)
    assert 2 == Range.hits(6, 2)
    assert 2 == Range.hits(12, 1)

    #min/max
    assert 6 == Range.hits(6, 6)
    assert 0 == Range.hits(0, 6)
    assert 0 == Range.hits(1, 0)

    #illegal
    assert {:error, "dice cannot be negative"} == Range.hits(-1, 1)
    assert {:error, "eyes cannot be negative"} == Range.hits(1, -1)
    assert {:error, "eyes cannot excced 6"} == Range.hits(1, 7)
  end

  #same as hits until rerolls appear
  test "probable attack dice" do
    assert {1/2, 1/6} == Range.attacks(1, 3)
    assert {1/3, 1/6} == Range.attacks(1, 4)

    #min/max
    assert {0.0, 0.0} == Range.attacks(0, 6)
    assert {0.0, 1.0} == Range.attacks(6, 6)
    assert {4.0, 1.0} == Range.attacks(6, 2)

    #illegal
    assert {:error, "dice cannot be negative"} == Range.attacks(-1, 1)
    assert {:error, "skill cannot be less than 2"} == Range.attacks(1, 1)
    assert {:error, "skill cannot excced 6"} == Range.attacks(1, 7)
  end

  #same as hits until rerolls appear
  test "probable saves" do
    dice = 3

    #normal
    assert {0.5, 0.5} == Range.saves(dice, 5)
    assert {1.0, 0.5} == Range.saves(dice, 4)
    assert {1.5, 0.5} == Range.saves(dice, 3)

    #min/max
    assert {2.5, 0.5} == Range.saves(dice, 1)
    assert {0.0, 0.5} == Range.saves(dice, 6)

    #variation
    assert {2/3, 1/3} == Range.saves(2, 4)
    assert {1/3, 1/6} == Range.saves(1, 4)
    assert {0.0, 0.0} == Range.saves(0, 4)

    #illegal
    assert {:error, "dice cannot be negative"} == Range.saves(-1, 6)
    assert {:error, "save cannot be less than 1"} == Range.saves(dice, 0)
    assert {:error, "save cannot be greater than 6"} == Range.saves(dice, 7)
  end

  test "calculate damage" do
    #normal
    assert 3.0 = Range.damage(3, 2, 3)
    assert 4.5 = Range.damage(3, 3, 3)
    assert 6.0 = Range.damage(3, 4, 3)

    #min
    assert 0.0 = Range.damage(0, 3, 4)
    assert 0.0 = Range.damage(0, 6, 4)

    assert 0.0 = Range.damage(3, 0, 4)
    assert 0.0 = Range.damage(6, 0, 4)

    assert 0.0 = Range.damage(6, 3, 0)
    assert 0.0 = Range.damage(3, 6, 0)

    #illegal
    assert {:error, "dice cannot be negative"} == Range.damage(-1, 0, 0)
    assert {:error, "eyes cannot be negative"} == Range.damage(0, -1, 0)
    assert {:error, "eyes cannot excced 6"} == Range.damage(0, 7, 0)
    assert {:error, "damage cannot be negative"} == Range.damage(0, 0, -1)
  end

  test "calculate total damage" do
    #normal
    assert {3.0, 2.0} == Range.damage(3, 4, 3, 4)
    assert {4.5, 1.5} == Range.damage(3, 3, 3, 3)
    assert {5.33, 2.67} == Range.damage(4, 4, 4, 4)
    assert {10.0, 6.67} == Range.damage(10, 4, 3, 4)
    assert {5.0, 3.0} == Range.damage(3, 4, 5, 6)
    assert {4.0, 1.5} == Range.damage(3, 2, 2, 3)

    #min
    assert {0.0, 0.0} == Range.damage(0, 4, 3, 4)
    assert {0.0, 2.0} == Range.damage(3, 6, 3, 4)

    #max
    assert {7.5, 2.0} == Range.damage(3, 1, 3, 4)
    assert {7.5, 0.0} == Range.damage(3, 1, 3, 0)
    assert {0.0, 2.0} == Range.damage(3, 1, 0, 4)

    #fractal
    assert {3.75, 1.67} == Range.damage(2.5, 3, 3, 4)
    assert {1.5, 0.67} == Range.damage(1.0, 3, 3, 4)
    assert {0.75, 0.33} == Range.damage(0.5, 3, 3, 4)

    #illegal
    assert {:error, "dice cannot be negative"} == Range.damage(-1, 0, 0, 0)
    assert {:error, "skill cannot be less than 1"} == Range.damage(0, 0, 0, 0)
    assert {:error, "skill cannot excced 6"} == Range.damage(0, 7, 0, 0)
    assert {:error, "damage cannot be negative"} == Range.damage(0, 1, -1, 0)
    assert {:error, "damage cannot be negative"} == Range.damage(0, 1, 0, -1)
  end

  test "calculate saves" do
    dice = 3

    #normal
    assert {0.5, 0.5} == Range.saves(dice, 5)
    assert {1.0, 0.5} == Range.saves(dice, 4)
    assert {1.5, 0.5} == Range.saves(dice, 3)

    #min/max
    assert {2.5, 0.5} == Range.saves(dice, 1)
    assert {0.0, 0.5} == Range.saves(dice, 6)

    #variation
    assert {2/3, 1/3} == Range.saves(2, 4)
    assert {1/3, 1/6} == Range.saves(1, 4)
    assert {0.0, 0.0} == Range.saves(0, 4)

    #illegal
    assert {:error, "dice cannot be negative"} == Range.saves(-1, 6)
    assert {:error, "save cannot be less than 1"} == Range.saves(dice, 0)
    assert {:error, "save cannot be greater than 6"} == Range.saves(dice, 7)
  end

  test "calculate open" do
    #even
    assert {0.0, 0.0} == Range.in_open([3, 4, 3, 4, 4])

    #damage
    assert {3.0, 4.0} == Range.in_open([3, 3, 3, 4, 5])

    #oversave
    assert {0.0, 0.0} == Range.in_open([3, 5, 3, 4, 3])

    #illegal
  end
end
