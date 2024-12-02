defmodule Helpers do
  def toListWithWeight [left|[right]] do
    left |> Enum.map(fn leftItem -> {leftItem, Enum.count(right, fn rightItem -> rightItem == leftItem end)} end)
  end
end

test = false
filePath = if test, do: "test-data.txt", else: "data.txt"

{:ok, rawData} = File.read(filePath)

rawData
  |> String.split("\n", trim: true)
  |> Enum.map(fn line -> line |> String.split("   ", trim: true) |> Enum.map(&String.to_integer/1) end)
  |> Enum.filter(fn line -> line != "" end)
  |> IO.inspect(label: "input")
  |> Enum.zip()
  |> Enum.map(&Tuple.to_list/1)
  |> IO.inspect(label: "2 lists")
  |> Helpers.toListWithWeight()
  |> IO.inspect(label: "left with weight")
  |> Enum.map(fn {a, b} -> a * b end)
  |> IO.inspect(label: "similarity scores")
  |> Enum.sum
  |> IO.inspect(label: "result")
