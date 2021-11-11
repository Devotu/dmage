defmodule DmageWeb.MainLive do
  use DmageWeb, :live_view

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
        {:noreply, assign(socket, results: [inputs |> calculate] ++ socket.assigns.results)}
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
    valid = inputs
    |> Enum.map(&Integer.parse/1)
    |> Enum.member?(:error)
    |> then(&(!&1))

    {valid, inputs}
  end

  defp inputs_are_in_range({true, inputs}) do
    valid = inputs
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {n, ""} -> n end)
    |> Enum.min()
    |> then(&(&1 > 0))

    {valid, inputs}
  end
  defp inputs_are_in_range({false, _inputs} = error), do: error

  defp calculate(inputs) do
    inputs
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {n, ""} -> n end)
    |> calculate_in_open()
  end

  defp calculate_in_open([a, s, n, c]) do
    a + s + n + c
  end
end
