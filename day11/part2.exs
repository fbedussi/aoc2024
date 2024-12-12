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
    |> Enum.reduce(%{}, fn n, acc -> acc |> Map.put(n, 1) end)
  end
end

defmodule Helpers do
  def run(stones, 6) do
    stones
  end

  def run(stones, turn) do
    change_stones(stones, Map.keys(stones)) |> run(turn + 1)
  end

  def change_stones(stones, keys_to_process) do
  end

  def update_key(key, stones) do
    change_stone(key)
    |> Enum.each(fn stone ->
      Map.put(
        stones,
        IO.inspect(stone, label: "stone"),
        (stones[stone] || 0) + stones[IO.inspect(key, label: "key")]
      )
    end)

    stones |> IO.inspect(label: "stones")
  end

  def change_stone(stone) do
    cond do
      stone === 0 ->
        [1]

      Integer.to_string(stone) |> String.length() |> rem(2) === 0 ->
        split(stone)

      true ->
        [stone * 2024]
    end
  end

  def split(stone) do
    str = Integer.to_string(stone)

    str
    |> String.split_at(round(String.length(str) / 2))
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer/1)
  end

  def get_result(set) do
    set
    |> Map.values()
    |> Enum.sum()
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Helpers.run(0)
    |> Helpers.get_result()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

# Main.run(false)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 11 - Part 1 - test data" do
    assert Main.run(true) == 55312
  end

  @tag :skip
  test "Day 11 - Part 1 - real data" do
    assert Main.run(false) == 193_899
  end
end
