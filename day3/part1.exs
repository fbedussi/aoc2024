defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> IO.inspect(label: "input")
  end
end

defmodule Helpers do
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.map(fn line -> Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, line) end)
    |> List.flatten()
    |> Enum.map(fn line -> Regex.scan(~r/(\d{1,3}),(\d{1,3})/, line) |> hd() end)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  test "Day 3 - Part 1 - test data" do
    assert Main.run(true) == 161
  end

  # @tag :skip
  test "Day 3 - Part 1 - real data" do
    assert Main.run(false) == 536
  end
end
