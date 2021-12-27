defmodule Dmage.BenchmarkTest do
  use ExUnit.Case

  alias Dmage.Benchmark

  test "calculate hits" do
    assert 0 == Benchmark.measure(fn -> 2 * 2 end)
    assert 0 < Benchmark.measure(fn -> :timer.sleep(100) end)
  end
end
