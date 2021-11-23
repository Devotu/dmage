defmodule Dmage.Range.Runner do
  @faces 6
  @defence 3

  def hits(0, _eyes), do: 0
  def hits(_dice, 0), do: 0
  def hits(dice, _eyes) when dice < 0, do: error "dice cannot be negative"
  def hits(_dice, eyes) when eyes < 0, do: error "eyes cannot be negative"
  def hits(_dice, eyes) when eyes > @faces, do: error "eyes cannot excced #{@faces}"
  def hits(dice, eyes) do
    1..dice
    |> Enum.filter(fn _d -> is_hit(eyes) end)
    |> Enum.count()
  end

  def attacks(0, _skill), do: {0.0, 0.0}
  def attacks(dice, _skill) when dice < 0, do: error "dice cannot be negative"
  def attacks(_dice, skill) when skill < 2, do: error "skill cannot be less than 2"
  def attacks(_dice, skill) when skill > @faces, do: error "skill cannot excced #{@faces}"
  def attacks(dice, skill) do
    normal = hits(dice, @faces - skill)
    crit = hits(dice, 1)
    {normal, crit}
  end


  defp is_hit(eyes) do
    Enum.random(1..6) <= eyes
  end

  defp error(msg) do
    {:error, msg}
  end
end
