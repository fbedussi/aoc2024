require IEx
use Bitwise

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
  def calculate(n, 0), do: n
  def calculate(n, iterations) do
    n1 = n * 64 |> mix(n) |> prune
    n2 = trunc(n1 / 32) |> mix(n1) |> prune
    n3 = (n2 * 2048) |> mix(n2) |> prune
    calculate(n3, iterations - 1)
  end

  def mix(n1, n2), do: bxor(n1, n2)

  def prune(n), do: rem(n, 16777216)

  def keepUnits(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> hd()
    |> String.to_integer()
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.map(&Helpers.calculate(&1,2000))
    |> Enum.map(&Helpers.keepUnits/1)
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

# Helpers.calculate(123, 10)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 19 - Part 1 - test data" do
    assert Main.run(true) == 37327623
  end

  # @tag :skip
  test "Day 19 - Part 1 - real data" do
    assert Main.run(false) == 20411980517
  end
end
