defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rowIndex} ->
      row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
    end)
    |> Enum.reduce(%{}, fn {x, y, v}, acc -> acc |> Map.put({x, y}, {v, v === "^"}) end)
  end
end

defmodule Helpers do
  def visit(matrix, {coord, {cell_val, _}} = cell, direction) do
    matrix = Map.put(matrix, coord, {cell_val, true})

    move = get_move(direction)

    next_coord = move.(coord)
    next_cell = matrix[next_coord]

    evaluate_next_cell(next_coord, next_cell, matrix, cell, direction)
  end

  defp evaluate_next_cell(_, nil, matrix, _, _) do
    matrix
  end

  defp evaluate_next_cell(_, {"#", _}, matrix, cell, direction) do
    direction = turn(direction)
    visit(matrix, cell, direction)
  end

  defp evaluate_next_cell(next_coord, next_cell, matrix, _, direction) do
    visit(matrix, {next_coord, next_cell}, direction)
  end

  def get_move(direction) do
    %{
      up: fn {x, y} -> {x, y - 1} end,
      down: fn {x, y} -> {x, y + 1} end,
      left: fn {x, y} -> {x - 1, y} end,
      right: fn {x, y} -> {x + 1, y} end
    }[String.to_atom(direction)]
  end

  def turn(direction) do
    %{
      up: "right",
      right: "down",
      down: "left",
      left: "up"
    }[String.to_atom(direction)]
  end
end

defmodule Main do
  def run(isTest) do
    matrix = InputHelpers.parse(isTest)

    start =
      matrix
      |> Enum.find(fn {_, {val, _}} -> val === "^" end)

    Helpers.visit(matrix, start, "up")
    |> Enum.count(fn {_, {_, visited}} -> visited end)
    |> IO.inspect(
      label:
        if isTest do
          "test result"
        else
          "real result"
        end
    )
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 6 - Part 1 - test data" do
    assert Main.run(true) == 41
  end

  # @tag :skip
  test "Day 6 - Part 1 - real data" do
    assert Main.run(false) == 4711
  end
end
