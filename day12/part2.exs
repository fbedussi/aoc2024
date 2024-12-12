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
    |> Enum.reduce(%{}, fn {x, y, v}, acc ->
      acc |> Map.put({x, y}, {v, v === "^", nil})
    end)
  end
end

defmodule Helpers do
  def try_new_obstacles(matrix, start, coords_to_try) do
    try_new_obstacles(matrix, start, coords_to_try, [])
  end

  def try_new_obstacles(_, _, [], result) do
    result
  end

  def try_new_obstacles(original_matrix, start, [coord_to_try | other_coords_to_try], result) do
    modified_matrix = Map.put(original_matrix, coord_to_try, {"#", false, nil})

    result = [Helpers.visit(modified_matrix, start, "up") | result]

    try_new_obstacles(original_matrix, start, other_coords_to_try, result)
  end

  def visit(matrix, {coord, {cell_val, visited, with_direction}} = cell, direction) do
    matrix = Map.put(matrix, coord, {cell_val, true, direction})

    if visited && with_direction === direction do
      true
    else
      move = get_move(direction)

      next_coord = move.(coord)
      next_cell = matrix[next_coord]

      if next_cell do
        {next_cell_val, _, _} = next_cell

        if next_cell_val === "#" do
          direction = turn(direction)
          visit(matrix, cell, direction)
        else
          visit(matrix, {next_coord, next_cell}, direction)
        end
      else
        false
      end
    end
  end

  def get_move(direction) do
    direction_map = %{
      up: fn {x, y} -> {x, y - 1} end,
      down: fn {x, y} -> {x, y + 1} end,
      left: fn {x, y} -> {x - 1, y} end,
      right: fn {x, y} -> {x + 1, y} end
    }

    direction_map[String.to_atom(direction)]
  end

  def turn(direction) do
    turn_map = %{
      up: "right",
      right: "down",
      down: "left",
      left: "up"
    }

    turn_map[String.to_atom(direction)]
  end
end

defmodule Main do
  def run(isTest) do
    matrix = InputHelpers.parse(isTest)

    coords_to_try =
      matrix
      |> Map.to_list()
      |> Enum.filter(fn {_, {val, _, _}} -> val === "." end)
      |> Enum.map(fn {coord, _} -> coord end)

    start =
      matrix
      |> Enum.find(fn {_, {val, _, _}} -> val === "^" end)

    Helpers.try_new_obstacles(matrix, start, coords_to_try)
    |> Enum.count(&Function.identity/1)
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
  test "Day 6 - Part 2 - test data" do
    assert Main.run(true) == 6
  end

  # @tag :skip
  test "Day 6 - Part 2 - real data" do
    assert Main.run(false) == 1562
  end
end
