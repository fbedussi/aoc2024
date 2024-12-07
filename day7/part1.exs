defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> line |> String.split(": ", trim: true) end)
    |> Enum.map(fn [result, data] ->
      {String.to_integer(result),
       data |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)}
    end)
  end
end

defmodule Helpers do
  def test({result, numbers}) do
    number_of_operators = Integer.pow(2, length(numbers) - 1)

    combinations =
      Enum.to_list(0..(number_of_operators - 1))
      |> Enum.map(fn x -> Integer.to_string(x, 2) end)

    max_length = Enum.max(combinations |> Enum.map(&String.length/1))

    combinations
    |> Enum.map(fn str -> String.pad_leading(str, max_length, "0") end)
    |> Enum.any?(&test_combination(&1, numbers, result))
  end

  def test_combination(combination, numbers, result) do
    operators =
      combination
      |> String.split("", trim: true)

    result === calculate(numbers, operators)
  end

  def calculate([a | [b | c]], [operator | other_operators]) do
    result = if operator === "0", do: a + b, else: a * b

    if c === [] do
      result
    else
      calculate([result | c], other_operators)
    end
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.filter(&Helpers.test/1)
    |> Enum.map(fn {result, _} -> result end)
    |> Enum.sum()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 7 - Part 1 - test data" do
    assert Main.run(true) == 3749
  end

  # @tag :skip
  test "Day 7 - Part 1 - real data" do
    assert Main.run(false) == 1_298_103_531_759
  end
end
