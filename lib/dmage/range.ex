defmodule Dmage.Calculator.Range do
  @faces 6

  def hits(dice, _eyes) when dice < 0, do: error "dice cannot be negative"
  def hits(_dice, eyes) when eyes < 0, do: error "eyes cannot be negative"
  def hits(_dice, eyes) when eyes > @faces, do: error "eyes cannot excced #{@faces}"
  def hits(dice, eyes) do
    dice * (eyes / @faces)
  end

  def attacks(dice, _skill) when dice < 0, do: error "dice cannot be negative"
  def attacks(_dice, skill) when skill < 2, do: error "skill cannot be less than 2"
  def attacks(_dice, skill) when skill > @faces, do: error "skill cannot excced #{@faces}"
  def attacks(dice, skill) do
    normal = hits(dice, @faces - skill)
    crit = hits(dice, 1)
    {normal, crit}
  end

  def saves(dice, _save) when dice < 0, do: error "dice cannot be negative"
  def saves(_dice, save) when save < 0, do: error "save cannot be negative"
  def saves(_dice, save) when save > @faces, do: error "save cannot be greater than #{@faces}"
  def saves(_dice, save) when save < 1, do: error "save cannot be less than 1"
  def saves(defence, save) do
    normal = hits(defence, @faces - save)
    crit = hits(defence, 1)
    {normal, crit}
  end

  def resolve({hits_normal, hits_crit}, {saves_normal, saves_crit}, {damage_normal, damage_crit}) do
    damage_normal = damage(hits_normal - saves_normal, damage_normal)
    damage_crit = damage(hits_crit - saves_crit, damage_crit)
    {damage_normal, damage_crit}
  end

  def damage(hits, _damage) when hits <= 0, do: 0.0
  def damage(_hits, damage) when damage <= 0, do: 0.0
  def damage(hits, damage) do
    hits * damage
    |> Float.round(2)
  end

  defp error(msg) do
    {:error, msg}
  end
end
