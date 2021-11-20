defmodule Dmage.CalculatorRangeTest do
  use ExUnit.Case

  alias Dmage.Range.Calculator

  test "calculate hits" do
    assert 1/6 == Calculator.hits(1, 1)
    assert 1/2 == Calculator.hits(1, 3)

    assert 1 == Calculator.hits(6, 1)
    assert 2 == Calculator.hits(6, 2)
    assert 2 == Calculator.hits(12, 1)

    #min/max
    assert 6 == Calculator.hits(6, 6)
    assert 0 == Calculator.hits(0, 6)
    assert 0 == Calculator.hits(1, 0)

    #illegal
    assert {:error, "dice cannot be negative"} == Calculator.hits(-1, 1)
    assert {:error, "eyes cannot be negative"} == Calculator.hits(1, -1)
    assert {:error, "eyes cannot excced 6"} == Calculator.hits(1, 7)
  end

  #rerolls not accounted for
  test "probable attack dice" do
    assert {1/2, 1/6} == Calculator.attacks(1, 3)
    assert {1/3, 1/6} == Calculator.attacks(1, 4)

    assert {2.0, 2/3} == Calculator.attacks(4, 3)
    assert {4/3, 2/3} == Calculator.attacks(4, 4)

    #min/max
    assert {0.0, 0.0} == Calculator.attacks(0, 6)
    assert {0.0, 1.0} == Calculator.attacks(6, 6)
    assert {4.0, 1.0} == Calculator.attacks(6, 2)

    #illegal
    assert {:error, "dice cannot be negative"} == Calculator.attacks(-1, 1)
    assert {:error, "skill cannot be less than 2"} == Calculator.attacks(1, 1)
    assert {:error, "skill cannot excced 6"} == Calculator.attacks(1, 7)
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
    assert 5.17 == Calculator.probable_damage_in_open(4, 3, 3, 4, 5)
    assert 0.0 == Calculator.probable_damage_in_open(3, 4, 2, 3, 4)
    assert 14.5 == Calculator.probable_damage_in_open(5, 3, 5, 6, 6)
    assert 0.0 == Calculator.probable_damage_in_open(3, 5, 2, 3, 3)
  end

  #doubling up on crits not implemented
  test "probable in cover" do
    assert 3.33 == Calculator.probable_damage_in_cover(4, 3, 3, 4, 5)
    assert 0.5 == Calculator.probable_damage_in_cover(3, 4, 2, 3, 4)
    assert 10.5 == Calculator.probable_damage_in_cover(5, 3, 5, 6, 6)
    assert 0.5 == Calculator.probable_damage_in_cover(3, 5, 2, 3, 3)
  end
end
