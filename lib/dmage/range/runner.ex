defmodule Dmage.Range.Runner do
  @faces 6
  @defence 3

  def hits(dice, _eyes) when dice < 0, do: error "dice cannot be negative"
  def hits(_dice, eyes) when eyes < 0, do: error "eyes cannot be negative"
  def hits(_dice, eyes) when eyes > @faces, do: error "eyes cannot excced #{@faces}"
  def hits(dice, eyes) do
    dice * (eyes / @faces)
  end

  defp error(msg) do
    {:error, msg}
  end
end
