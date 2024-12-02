defmodule Helpers do
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
    if (checkDiff(item, next)) do
      diffIsOk([next | rest])
    else
      false
    end
  end
end

test =  false
filePath = if test, do: "test-data.txt", else: "data.txt"

{:ok, rawData} = File.read(filePath)

rawData
  |> String.split("\n", trim: true)
  |> Enum.map(fn line -> line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1) end)
  |> Enum.filter(fn line -> line != "" end)
  |> IO.inspect(label: "input")

  |> Enum.filter(&Helpers.isSafe/1)
  |> length
  |> IO.inspect(label: "result")
# 490
