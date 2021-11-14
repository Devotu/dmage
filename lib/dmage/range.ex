defmodule Dmage.Calculator.Range do
  @faces 6

  def damage_in_open([attack_dice, skill, normal_damage, _crit_damage, _save]) do
    hit_eyes = @faces - skill
    damage(attack_dice, hit_eyes, normal_damage)
  end

  def crit_in_open([attack_dice, _skill, _normal_damage, crit_damage, _save]) do
    damage(attack_dice, 1, crit_damage)
  end

  def damage(dice, _eyes, _damage) when dice < 0, do: {:error, "dice cannot be negative"}
  def damage(_dice, eyes, _damage) when eyes < 0, do: {:error, "eyes cannot be negative"}
  def damage(_dice, eyes, _damage) when eyes > @faces, do: {:error, "eyes cannot excced #{@faces}"}
  def damage(_dice, _eyes, damage) when damage < 0, do: {:error, "damage cannot be negative"}
  def damage(attack_dice, hit_eyes, damage) do
    hits = attack_dice * (hit_eyes / @faces)
    hits * damage
    |> Float.round(2)
  end

  def damage(dice, _skill, _damage_normal, _damage_crit) when dice < 0, do: {:error, "dice cannot be negative"}
  def damage(_dice, skill, _damage_normal, _damage_crit) when skill < 0, do: {:error, "skill cannot be less than 1"}
  def damage(_dice, skill, _damage_normal, _damage_crit) when skill > @faces, do: {:error, "skill cannot excced #{@faces}"}
  def damage(_dice, _skill, damage_normal, _damage_crit) when damage_normal < 0, do: {:error, "damage cannot be negative"}
  def damage(_dice, _skill, _damage_normal, damage_crit) when damage_crit < 0, do: {:error, "damage cannot be negative"}
  def damage(attack_dice, skill, damage_normal, damage_crit) do
    normal = damage(attack_dice, @faces - skill, damage_normal)
    crit = damage(attack_dice, 1, damage_crit)
    {normal, crit}
  end

  def saves(dice, _save) when dice < 0, do: {:error, "dice cannot be negative"}
  def saves(_dice, save) when save < 0, do: {:error, "save cannot be negative"}
  def saves(_dice, save) when save > @faces, do: {:error, "save cannot be greater than #{@faces}"}
  def saves(_dice, save) when save < 1, do: {:error, "save cannot be less than 1"}
  def saves(defence, save) do
    normal = hits(defence, @faces - save)
    crit = hits(defence, 1)
    {normal, crit}
  end

  def hits(dice, _eyes) when dice < 0, do: {:error, "dice cannot be negative"}
  def hits(_dice, eyes) when eyes < 0, do: {:error, "eyes cannot be negative"}
  def hits(_dice, eyes) when eyes > @faces, do: {:error, "eyes cannot excced #{@faces}"}
  def hits(dice, eyes) do
    dice * (eyes / @faces)
  end
end
