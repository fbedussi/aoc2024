require IEx

defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(7)
    |> Enum.map(fn schema -> schema |> Enum.map(&String.split(&1,"", trim: true)) end)
    |> Enum.map(fn schema -> schema |> Enum.zip_with(&Function.identity/1) end)
    |> Enum.reduce({[], []}, fn [[c | _]|_] = schema, {locks, keys} -> if c === "#", do: {[schema |> convert() | locks], keys}, else: {locks, [schema |> convert() | keys]} end)
  end

  def convert(schema) do
    schema
    |> Enum.map(fn row -> row
        |> Enum.filter(fn c -> c === "#" end)
        |> length() end)
  end
end

defmodule Helpers do
  def count_valid({locks, keys}) do
    locks |> Enum.reduce(0, fn lock, result ->
      result + (keys |> Enum.filter(fn key -> is_compatible(lock, key) end) |> length())
    end)
  end

  defp is_compatible(lock, key) do
    Enum.zip(lock, key) |> Enum.all?(fn {a,b} -> a + b <= 7 end)
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Helpers.count_valid()
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

  @tag :skip
  test "Day 25 - Part 1 - test data" do
    assert Main.run(true) == 3
  end

  # @tag :skip
  test "Day 25 - Part 1 - real data" do
    assert Main.run(false) == 3264
  end
end
