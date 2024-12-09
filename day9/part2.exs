defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> hd()
  end
end

defmodule Helpers do
  def convert(str) do
    arr =
      str
      |> String.split("", trim: true)

    [blocksH | blocksT] =
      arr
      |> Enum.take_every(2)
      |> Enum.with_index()
      |> Enum.map(fn {val, i} -> {i, String.to_integer(val), false} end)

    spaces =
      arr
      |> tl()
      |> Enum.take_every(2)
      |> Enum.map(fn val -> {nil, String.to_integer(val), nil} end)

    Enum.concat([[blocksH], List.zip([spaces, blocksT]) |> Enum.map(fn {a, b} -> [a, b] end)])
    |> List.flatten()
  end

  def compact(arr) do
    arr
    |> Enum.with_index()
    |> do_compact()
  end

  defp do_compact(arr) do
    file_to_move =
      Enum.find(
        arr |> Enum.reverse(),
        fn {{val, _, processed}, _} ->
          val !== nil && processed === false
        end
      )

    do_compact(arr, file_to_move)
  end

  defp do_compact(arr, nil) do
    arr
  end

  defp do_compact(
         arr,
         {{_, file_to_move_length, _}, file_to_move_index} = file_to_move
       ) do
    space =
      arr
      |> Enum.find(fn {{val, length, _}, _} ->
        val === nil && length >= file_to_move_length
      end)

    no_space_available =
      space === nil || elem(space, 1) >= file_to_move_index

    if no_space_available do
      arr =
        arr
        |> List.update_at(file_to_move_index, fn {{val, length, _}, _} ->
          {{val, length, true}, file_to_move_index}
        end)

      do_compact(arr)
    else
      do_compact(arr, file_to_move, space)
    end
  end

  def do_compact(
        arr,
        {{file_to_move_id, file_to_move_length, _}, file_to_move_index},
        {{_, space_length, _}, space_index}
      ) do
    if space_length === file_to_move_length do
      arr =
        arr
        |> List.update_at(space_index, fn _ ->
          {{file_to_move_id, file_to_move_length, true}, space_index}
        end)
        |> List.update_at(file_to_move_index, fn _ ->
          {{nil, file_to_move_length, nil}, file_to_move_index}
        end)

      do_compact(arr)
    else
      arr =
        arr
        |> List.update_at(space_index, fn _ ->
          [
            {{file_to_move_id, file_to_move_length, true}, space_index},
            {{nil, space_length - file_to_move_length, nil}, space_index}
          ]
        end)
        |> List.update_at(file_to_move_index, fn _ ->
          {{nil, file_to_move_length, nil}, file_to_move_index}
        end)
        |> List.flatten()
        |> Enum.map(fn {data, _} -> data end)
        |> Enum.with_index()

      do_compact(arr)
    end
  end

  def getResult(arr) do
    arr
    |> List.flatten()
    |> Enum.map(fn {{val, length, _}, _} -> {val, length} end)
    |> Enum.map(fn {val, length} -> List.duplicate(val, length) end)
    |> List.flatten()
    |> Enum.with_index()
    |> Enum.filter(fn {val, _} -> val !== nil end)
    |> Enum.map(fn {val, index} -> val * index end)
    |> Enum.sum()
  end
end

defmodule Main do
  def run(isTest) do
    InputHelpers.parse(isTest)
    |> Helpers.convert()
    |> Helpers.compact()
    |> Helpers.getResult()
    |> IO.inspect(label: if(isTest, do: "test result: ", else: "real result: "))
  end
end

defmodule Test do
  use ExUnit.Case

  ExUnit.start()

  # @tag :skip
  test "Day 9 - Part 2 - test data" do
    assert Main.run(true) == 2858
  end

  # @tag :skip
  test "Day 9 - Part 2 - real data" do
    assert Main.run(false) == 6_476_642_796_832
  end
end
