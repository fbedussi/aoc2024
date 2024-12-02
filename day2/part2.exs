defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.filter(fn line -> line != "" end)

    # |> IO.inspect(label: "input")
  end
end

defmodule Helpers do
  def explode(report) do
    [
      report
      | report
        |> Enum.with_index()
        |> Enum.map(fn {_, index} ->
          report |> List.delete_at(index)
        end)
    ]
  end

  def isSafe(report) do
    isSorted(report) && diffIsOk(report)
  end

  defp isSorted(report) do
    sorted = Enum.sort(report)
    report === sorted || Enum.reverse(report) === sorted
  end

  defp checkDiff(item, next) do
    diff = abs(item - next)
    diff >= 1 && diff <= 3
  end

  defp diffIsOk([item | [next | []]]) do
    checkDiff(item, next)
  end

  defp diffIsOk([item | [next | rest]]) do
    if checkDiff(item, next) do
      diffIsOk([next | rest])
    else
      false
    end
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Enum.map(&Helpers.explode/1)
    |> Enum.filter(fn permutations -> permutations |> Enum.any?(&Helpers.isSafe/1) end)
    |> length
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))

    # 536
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  test "Day 2 - Part 2 - test data" do
    assert Main.run(true) == 4
  end

  test "Day 2 - Part 2 - real data" do
    assert Main.run(false) == 536
  end
end
