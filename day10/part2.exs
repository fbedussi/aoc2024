defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    matrix =
      rawData
      |> String.split("\n", trim: true)
      |> Enum.filter(fn line -> line != "" end)
      |> Enum.map(fn line ->
        line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    max_x = matrix |> hd() |> length() |> Kernel.-(1)
    max_y = matrix |> length() |> Kernel.-(1)

    matrix
    |> Enum.map(&Enum.with_index/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rowIndex} ->
      row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
    end)
    |> Enum.reduce(%{}, fn {x, y, v}, acc ->
      acc
      |> Map.put({x, y}, %{
        n: v,
        neighbors:
          [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]
          |> Enum.filter(fn {x, y} -> x >= 0 && x <= max_x && y >= 0 && y <= max_y end)
      })
    end)
  end
end

defmodule Helpers do
  def findHeads(matrix) do
    matrix
    |> Map.filter(fn {_, val} -> val.n === 0 end)
    |> Map.keys()
  end

  def getScore(current, matrix, result) do
    matrix[current].neighbors
    |> Enum.map(fn neighbor ->
      cond do
        matrix[current].n === 8 && matrix[neighbor].n === 9 ->
          1

        matrix[neighbor].n === matrix[current].n + 1 ->
          getScore(neighbor, matrix, result)

        true ->
          result
      end
    end)
    |> Enum.sum()
  end
end

defmodule Main do
  def run(isTest) do
    matrix =
      InputHelpers.parse(isTest)

    matrix
    |> Helpers.findHeads()
    |> Enum.map(&Helpers.getScore(&1, matrix, 0))
    |> Enum.sum()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 10 - Part 1 - test data" do
    assert Main.run(true) == 81
  end

  # @tag :skip
  test "Day 10 - Part 1 - real data" do
    assert Main.run(false) == 1497
  end
end
