defmodule DmageWeb.MainLive do
  use DmageWeb, :live_view

  @faces 6

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, attack: 0, results: [])}
  end

  @impl true
  def handle_event("calculate", %{"attack" => a, "skill" => s, "damage_normal" => n, "damage_crit" => c}, socket) do
    inputs = [a, s, n, c]
    case is_valid_input(inputs) do
      {false, _inputs} ->
        {:noreply, put_flash(socket, :feedback, "Invalid input")}
      _ ->
        pretty_input = inputs |> inputs_to_numbers()
        open_normal_damage = pretty_input |> calculate_normal_in_open()
        open_crit_damage = pretty_input |> calculate_crit_in_open()
        result = %{
          input: pretty_input,
          open: %{
            normal_damage: open_normal_damage,
            crit_damage: open_crit_damage,
            total_damage: open_normal_damage + open_crit_damage,
          },
        }
        {:noreply, assign(socket, results: [Kernel.inspect(result)] ++ socket.assigns.results)}
    end
  end

  ## Validation
  defp is_valid_input(inputs) do
    {true, inputs}
    |> inputs_are_numbers()
    |> inputs_are_in_range()
  end

  ## Helpers
  defp inputs_are_numbers({true, inputs}) do
    valid = inputs_to_numbers(inputs)
    |> Enum.member?(:error)
    |> then(&(!&1))

    {valid, inputs}
  end

  defp inputs_are_in_range({true, inputs}) do
    valid = inputs_to_numbers(inputs)
    |> Enum.min()
    |> then(&(&1 > 0))

    {valid, inputs}
  end
  defp inputs_are_in_range({false, _inputs} = error), do: error

  defp calculate_normal_in_open([attack_dice, skill, normal_damage, _crit_damage]) do
    hit_eyes = @faces - skill
    calculate_damage(attack_dice, hit_eyes, normal_damage)
  end

  defp calculate_crit_in_open([attack_dice, _skill, _normal_damage, crit_damage]) do
    calculate_damage(attack_dice, 1, crit_damage)
  end

  defp calculate_damage(attack_dice, hit_eyes, damage) do
    hits = attack_dice * (hit_eyes / @faces)
    hits * damage
  end

  defp inputs_to_numbers(inputs) do
    inputs
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {n, ""} -> n end)
  end
end
