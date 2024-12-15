require IEx

defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    [map_raw, movements] =
      rawData
      |> String.split("\n")
      |> Enum.chunk_by(fn line -> line === "" end)
      |> Enum.filter(fn line -> line !== [""] end)

    map =
      map_raw
      |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, rowIndex} ->
        row |> Enum.map(fn {val, colIndex} -> {colIndex, rowIndex, val} end)
      end)
      |> Enum.reduce(%{}, fn {x, y, v}, acc -> acc |> Map.put({x, y}, v) end)

    movements =
      movements
      |> Enum.join("")
      |> String.split("", trim: true)

    {position, _} = map |> Map.to_list() |> Enum.find(fn {_, v} -> v === "@" end)

    cols = map_raw |> hd() |> String.length()
    rows = map_raw |> length()

    {map |> Map.put(position, "."), movements, position, cols, rows}
    |> tap(&Print.print(&1))
  end
end

defmodule Print do
  def print({index, movement, position, cols, rows}) do
    IO.puts("")
    IO.puts(movement)
    print_line(index, position, cols, rows, 0)
    # require IEx
    # IEx.pry()
  end

  def print_line(index, position, cols, rows, row) do
    line = build_line(index, position, cols - 1, row, [])
    IO.puts(line)

    if row < rows do
      print_line(index, position, cols, rows, row + 1)
    end
  end

  def build_line(_, _, -1, _, line) do
    line |> Enum.join("")
  end

  def build_line(index, {posx, posy}, col, row, line) do
    build_line(index, {posx, posy}, col - 1, row, [
      if(col === posx && row === posy, do: "@", else: index[{col, row}]) | line
    ])
  end
end

defmodule Helpers do
  def move({map, [], _, _, _}) do
    map
  end

  def move({map, [movement | movements], position, cols, rows}) do
    {map, position} = update(map, movement, position)
    # Print.print({map, movement, position, cols, rows})
    # IEx.pry()

    move({map, movements, position, cols, rows})
  end

  def update(map, movement, {x, y} = position) do
    # IEx.pry()

    updated_position =
      cond do
        movement === "^" -> {x, y - 1}
        movement === ">" -> {x + 1, y}
        movement === "v" -> {x, y + 1}
        movement === "<" -> {x - 1, y}
      end

    # IEx.pry()

    cond do
      map[updated_position] === "#" -> {map, position}
      map[updated_position] === "." -> {map, updated_position}
      map[updated_position] === "O" -> move_box(map, movement, updated_position, position)
    end
  end

  def move_box(map, movement, {x, y} = box_position, robot_position) do
    updated_box_position =
      cond do
        movement === "^" -> {x, y - 1}
        movement === ">" -> {x + 1, y}
        movement === "v" -> {x, y + 1}
        movement === "<" -> {x - 1, y}
      end

    cond do
      map[updated_box_position] === "#" ->
        {map, robot_position}

      map[updated_box_position] === "." ->
        {map |> Map.put(box_position, ".") |> Map.put(updated_box_position, "O"), box_position}

      map[updated_box_position] === "O" ->
        {map, new_updated_box_position} =
          move_box(map, movement, updated_box_position, box_position)

        if new_updated_box_position !== box_position do
          map = map |> Map.put(box_position, ".") |> Map.put(new_updated_box_position, "O")
          {map, box_position}
        else
          {map, robot_position}
        end
    end
  end

  def calculate(map) do
    map
    |> Map.to_list()
    |> Enum.filter(fn {_, v} -> v === "O" end)
    |> Enum.map(fn {{x, y}, _} -> 100 * y + x end)
    |> Enum.sum()
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Helpers.move()
    |> Helpers.calculate()
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
  test "Day 15 - Part 1 - test data" do
    assert Main.run(true) == 10092
  end

  #
  # @tag :skip
  test "Day 15 - Part 1 - real data" do
    assert Main.run(false) == 1_437_174
  end
end
