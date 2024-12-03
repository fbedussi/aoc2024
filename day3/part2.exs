defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data2.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)

    # |> IO.inspect(label: "input")
  end
end

defmodule Helpers do
  def process(list) do
    process(list, [], true)
  end

  defp process([], result, take) do
    result
  end

  defp process([item | list], result, take) do
    case {list, item, take} do
      {_, "do()", _} -> process(list, result, true)
      {_, "don't()", _} -> process(list, result, false)
      {_, _, false} -> process(list, result, false)
      {_, mul, true} -> process(list, [mul | result], true)
    end
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.map(fn line ->
      Regex.scan(~r/do\(\)|don't\(\)|mul\(\d{1,3},\d{1,3}\)/, line)
    end)
    |> List.flatten()
    |> Helpers.process()
    |> Enum.map(fn instruction ->
      Regex.scan(~r/mul\((\d{1,3},\d{1,3})\)/, instruction) |> hd() |> Enum.reverse() |> hd()
    end)
    |> Enum.map(fn line -> line |> String.split(",") |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))

    # 106921067
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 3 - Part 2 - test data" do
    assert Main.run(true) == 48
  end

  # @tag :skip
  test "Day 3 - Part 2 - real data" do
    assert Main.run(false) == 106_921_067
  end
end
