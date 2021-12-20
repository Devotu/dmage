defmodule DmageWeb.RangeLive do
  use DmageWeb, :live_view

  alias Dmage.Range.Calculator

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, attack: 0, results: [])}
  end

  @impl true
  def handle_event("execute", %{"attack" => a, "skill" => s, "damage_normal" => n, "damage_crit" => c, "save" => save, "cover" => cover}, socket) do
    inputs = [a, s, n, c, save]
    is_cover = checked? cover

    case is_valid_input(inputs) do
      {false, _inputs} ->
        {:noreply, put_flash(socket, :feedback, "Invalid input")}
      _ ->
        pretty_inputs = inputs |> inputs_to_numbers()
        damage = pretty_inputs |> calculate_damage(is_cover)

        result = %{
          input: pretty_inputs,
          cover: is_cover,
          damage: damage,
        }

        {:noreply, assign(socket, results: [Kernel.inspect(result)] ++ socket.assigns.results)}
    end
  end
  def handle_event("execute", input, socket) when is_map(input) do
    handle_event("execute", Map.put(input, "cover", "off"), socket)
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

  defp inputs_to_numbers(inputs) do
    inputs
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {n, ""} -> n end)
  end

  defp calculate_damage(inputs, false) do
    Calculator.probable_damage_in_open inputs
  end
  defp calculate_damage(inputs, true) do
    Calculator.probable_damage_in_cover inputs
  end

  defp checked?("on"), do: true
  defp checked?(_), do: false
end
