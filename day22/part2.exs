import Bitwise

defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Helpers do
  def calculate(_, 0, result), do: result |> Enum.reverse()
  def calculate(n, iterations, result) do
    n1 = n * 64 |> mix(n) |> prune
    n2 = trunc(n1 / 32) |> mix(n1) |> prune
    n3 = (n2 * 2048) |> mix(n2) |> prune
    calculate(n3, iterations - 1, [n3 | result])
  end

  def mix(n1, n2), do: bxor(n1, n2)

  def prune(n), do: rem(n, 16777216)

  def keep_units(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.at(0)
    |> String.to_integer()
  end

  def with_difference(numbers) do
    with_difference(numbers, [])
  end

  defp with_difference([_|[]], result) do
    result |> Enum.reverse()
  end
  defp with_difference([n1| [n2 | others]], result) do
    with_difference([n2 | others], [{n2, n2-n1} | result])
  end


  def sequence([_,_,_], result), do: result
  def sequence([{_, d1} | [{r2, d2} | [{r3, d3} | [{r4, d4} | rest]]]], result) do
    result = if result[{d1,d2,d3,d4}] === nil do
      Map.put(result,{d1,d2,d3,d4}, r4)
    else
      result
    end
    sequence([{r2, d2} | [{r3, d3} | [{r4, d4} | rest]]], result)
  end

  def calculate_bananas(sequence, sequence_maps) do
    sequence_maps
    |> Enum.map(fn sequence_map -> sequence_map[sequence] || 0 end)
    |> Enum.sum()
  end
end

defmodule Main do
  def run(isTest) do
    sequence_results = InputHelpers.parse(isTest)
    |> Enum.map(&Helpers.calculate(&1,2000, []))
    |> Enum.map(fn sequence -> sequence |> Enum.map(&Helpers.keep_units/1) end)
    |> Enum.map(&Helpers.with_difference/1)
    |> Enum.map(&Helpers.sequence(&1, %{}))

    sequences = sequence_results
    |> Enum.flat_map(&Map.keys/1)
    |> Enum.sort()
    |> Enum.dedup()

    sequences
    |> Enum.map(fn sequence -> {sequence, Helpers.calculate_bananas(sequence, sequence_results)} end)
    |> Enum.sort_by(fn {_, a} -> a end)
    |> Enum.reverse()
    |> hd()
    |> IO.inspect(
      label:
        if isTest do
          "test result"
        else
          "real result"
        end
    )
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 19 - Part 2 - test data" do
    assert Main.run(true) == {{-9, 9, -1, 0}, 24}
  end

  # @tag :skip
  test "Day 19 - Part 2 - real data" do
    assert Main.run(false) == {{-2, 1, -1, 2}, 2362}
  end
end
