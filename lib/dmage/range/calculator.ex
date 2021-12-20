defmodule Dmage.Range.Calculator do
  @faces 6
  @defence 3

  def probable_damage_in_open([attacks, skill, damage_normal, damage_crit, save]) do
    hits = attacks(attacks, skill)
    saves = saves(@defence, save, 0)
    resolve(hits, saves, {damage_normal, damage_crit})
    |> Tuple.sum()
  end

  def probable_damage_in_cover([attacks, skill, damage_normal, damage_crit, save]) do
    hits = attacks(attacks, skill)
    saves = saves(@defence, save, 1)
    resolve(hits, saves, {damage_normal, damage_crit})
    |> Tuple.sum()
  end

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

  def saves(dice, _save, _retained) when dice < 0, do: error "dice cannot be negative"
  def saves(_dice, save, _retained) when save < 0, do: error "save cannot be negative"
  def saves(_dice, save, _retained) when save > @faces, do: error "save cannot be greater than #{@faces}"
  def saves(_dice, save, _retained) when save < 1, do: error "save cannot be less than 1"
  def saves(_dice, _save, retained) when retained > 3, do: error "retained cannot be greater than #{@defence}"
  def saves(defence, save, retained) when retained > 0 do
    {normal, crit} = saves(defence - retained, save, 0)
    {normal + retained, crit}
  end
  def saves(defence, save, _retained) do
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
    hits * damage * 1.0
    |> Float.round(2)
  end

  defp error(msg) do
    {:error, msg}
  end
end
