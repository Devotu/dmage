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
    |> Enum.map(fn _d -> is_hit(eyes) end)
    |> Enum.filter(fn h -> h end)
    |> Enum.count()
  end

  defp is_hit(eyes) do
    Enum.random(1..6) <= eyes
  end

  defp error(msg) do
    {:error, msg}
  end
end
