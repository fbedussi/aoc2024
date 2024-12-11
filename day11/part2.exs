defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> hd()
    |> then(fn line ->
      line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end
end

defmodule Helpers do
  def run(stones, 25) do
    stones
  end

  def run(stones, turn) do
    IO.puts(turn)
    run(change([], stones), turn + 1)
  end

  def change(prev, []) do
    prev
  end

  def change(prev, [current | next]) do
    change(change_stone(prev, current), next)
  end

  def change_stone(prev, stone) do
    cond do
      stone === 0 ->
        [1 | prev]

      Integer.to_string(stone) |> String.length() |> rem(2) === 0 ->
        {a, b} = split(stone)
        [a | [b | prev]]

      true ->
        [stone * 2024 | prev]
    end
  end

  def split(stone) do
    str = Integer.to_string(stone)

    {a, b} =
      str
      |> String.split_at(round(String.length(str) / 2))

    {String.to_integer(a), String.to_integer(b)}
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.map(fn n ->
      IO.puts("starting number")
      IO.puts(n)
      Helpers.run([n], 0)
    end)
    |> Enum.map(fn a -> length(a) end)
    |> Enum.sum()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

Main.run(false)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  @tag :skip
  test "Day 11 - Part 1 - test data" do
    assert Main.run(true) == 55312
  end

  @tag :skip
  test "Day 11 - Part 1 - real data" do
    assert Main.run(false) == 193_899
  end
end
