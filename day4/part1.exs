defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> linesToMap()
  end

  def linesToMap(lines) do
    lines
    |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rowIndex} ->
      row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
    end)
    |> Enum.reduce(%{}, fn {x, y, v}, acc -> acc |> Map.put({x, y}, v) end)
  end
end

defmodule Helpers do
  def get_x_coords(matrix) do
    matrix
    |> Map.to_list()
    |> Enum.filter(fn {_, v} -> v === "X" end)
  end

  def matches({{x, y}, v}, matrix) do
    matches({x, y}, matrix, v, 0)
  end

  defp matches({x, y}, matrix, expectedVal, result) do
    next_val = get_next_val(expectedVal)

    [
      matches({x, y}, fn {x, y} -> {x + 1, y} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x - 1, y} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x, y + 1} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x, y - 1} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x + 1, y + 1} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x + 1, y - 1} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x - 1, y + 1} end, matrix, next_val, result),
      matches({x, y}, fn {x, y} -> {x - 1, y - 1} end, matrix, next_val, result)
    ]
    |> Enum.sum()
  end

  defp matches(_, _, _, nil, result) do
    result + 1
  end

  defp matches({x, y}, updateCoords, matrix, expectedVal, result) do
    newCoords = updateCoords.({x, y})

    if matrix[newCoords] === expectedVal do
      next_val = get_next_val(expectedVal)
      matches(newCoords, updateCoords, matrix, next_val, result)
    else
      result
    end
  end

  defp get_next_val(val) do
    case val do
      "X" -> "M"
      "M" -> "A"
      "A" -> "S"
      "S" -> nil
    end
  end
end

defmodule Main do
  def run(isTest) do
    matrix = InputHelpers.parse(isTest)

    result =
      matrix
      |> Helpers.get_x_coords()
      |> Enum.map(&Helpers.matches(&1, matrix))
      |> Enum.sum()
      |> IO.inspect(
        label:
          if isTest do
            "test result"
          else
            "real result"
          end
      )

    result
  end
end

Main.run(true)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 4 - Part 1 - test data" do
    assert Main.run(true) == 18
  end

  # @tag :skip
  test "Day 4 - Part 1 - real data" do
    assert Main.run(false) == 2536
  end
end
