defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(fn part ->
        part
        |> String.slice(2..-1)
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end
end

defmodule Helpers do
  def simulate(data, t, cols, rows) do
    data
    |> Enum.map(&Helpers.calculate_position(&1, cols, rows, t))
    |> print(t, cols, rows)

    simulate(data, t + 1, cols, rows)
  end

  def print(data, t, cols, rows) do
    {_, ys} = data |> Enum.unzip()

    unique_ys =
      ys
      |> Enum.sort()
      |> Enum.dedup()
      |> length()

    # IO.puts(unique_xs)

    IO.puts(t)

    if unique_ys < 87 do
      index = data |> Enum.reduce(%{}, fn coord, result -> Map.put(result, coord, true) end)
      print_line(index, cols, rows, 0)
      require IEx
      IEx.pry()
    end
  end

  def print_line(index, cols, rows, row) do
    line = build_line(index, cols - 1, row, [])
    IO.puts(line)

    if row < rows do
      print_line(index, cols, rows, row + 1)
    end
  end

  def build_line(_, -1, _, line) do
    line |> Enum.join("")
  end

  def build_line(index, col, row, line) do
    build_line(index, col - 1, row, [if(index[{col, row}], do: "X", else: " ") | line])
  end

  def calculate_position({{x, y}, {vx, vy}}, cols, rows, t) do
    x = rem(x + vx * t, cols)
    y = rem(y + vy * t, rows)

    {if(x < 0, do: cols + x, else: x), if(y < 0, do: rows + y, else: y)}
  end
end

defmodule Main do
  def run(isTest, cols, rows) do
    InputHelpers.parse(isTest)
    # |> Enum.map(&Helpers.calculate_position(&1, cols, rows, 1))
    |> Helpers.simulate(1, cols, rows)
    # |> Helpers.calculate_factor(cols, rows)
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

Main.run(false, 101, 103)

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  @tag :skip
  test "Day 14 - Part 2 - test data" do
    assert Main.run(true, 11, 7) == 12
  end

  @tag :skip
  test "Day 14 - Part 2 - real data" do
    assert Main.run(false, 101, 103) == 226_236_192
  end

  # 8168
end
