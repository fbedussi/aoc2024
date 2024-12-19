require IEx

defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
    |> Enum.with_index()
  end
end

defmodule Print do
  def print({index, movement, position, cols, rows}) do
    IO.puts("")
    IO.puts(movement)
    print_line(index, position, cols, rows, 0)
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
end

# This module was initially produced by chatGPT
defmodule ReindeerMaze do
  # Directions: East, South, West, North
  @directions [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
  @turn_cost 1000
  @move_cost 1

  def find_lowest_score(maze) do
    {start, end_} = find_positions(maze)
    bfs(maze, start, end_)
  end

  defp find_positions(maze) do
    start = find_tile(maze, "S")
    stop = find_tile(maze, "E")
    {start, stop}
  end

  defp find_tile(maze, tile) do
    Enum.find_value(maze, fn {row, y} ->
      Enum.find_value(row, fn {c, x} -> if c == tile, do: {x, y}, else: nil end)
    end)
  end

  defp bfs(maze, start, stop) do
    # Queue stores tuples of {position, direction, cost}
    queue = :queue.new()
    visited = MapSet.new()

    queue =
      Enum.reduce(0..3, queue, fn direction, queue ->
        :queue.in({start, direction, 0}, queue)
      end)

    # Begin BFS
    bfs_loop(maze, queue, visited, stop)
  end

  defp bfs_loop(maze, queue, visited, stop) do
    case :queue.out(queue) do
      {:empty, _} ->
        # IEx.pry()
        :no_path_found

      {{:value, {pos, direction, score}}, queue} ->
        # IEx.pry()

        if pos == stop do
          IO.inspect(score, label: "score")
        else
          if MapSet.member?(visited, {pos, direction}) do
            bfs_loop(maze, queue, visited, stop)
          else
            visited = MapSet.put(visited, {pos, direction})

            neighbors = [
              move_forward(maze, pos, direction, score),
              turn_clockwise(pos, direction, score),
              turn_counter_clockwise(pos, direction, score)
            ]

            queue =
              Enum.reduce(neighbors, queue, fn new_state, queue ->
                :queue.in(new_state, queue)
              end)

            bfs_loop(maze, queue, visited, stop)
          end
        end
    end
  end

  defp move_forward(maze, {x, y}, direction, score) do
    {dx, dy} = Enum.at(@directions, direction)

    new_pos = {x + dx, y + dy}

    if valid_move?(maze, new_pos) do
      {new_pos, direction, score + @move_cost}
    else
      nil
    end
  end

  defp turn_clockwise({x, y}, direction, score) do
    new_direction = rem(direction + 1, 4)
    {{x, y}, new_direction, score + @turn_cost}
  end

  defp turn_counter_clockwise({x, y}, direction, score) do
    new_direction = rem(direction - 1, 4)
    {{x, y}, new_direction, score + @turn_cost}
  end

  defp valid_move?(maze, {x, y}) do
    # IEx.pry()

    case Enum.at(maze, y) do
      nil ->
        false

      {row, _} ->
        case Enum.at(row, x) do
          nil -> false
          ~c"#" -> false
          _ -> true
        end
    end
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> ReindeerMaze.find_lowest_score()
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
  test "Day 16 - Part 1 - test data" do
    assert Main.run(true) == 10092
  end

  # @tag :skip
  test "Day 16 - Part 1 - real data" do
    assert Main.run(false) == 1_437_174
  end
end
