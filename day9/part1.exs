defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> hd()

    # |> IO.inspect(label: "input")
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
      |> Enum.map(fn {val, i} -> List.duplicate(i, String.to_integer(val)) end)

    spaces =
      arr
      |> tl()
      |> Enum.take_every(2)
      |> Enum.map(fn val -> List.duplicate(nil, String.to_integer(val)) end)

    Enum.concat([[blocksH], List.zip([spaces, blocksT]) |> Enum.map(fn {a, b} -> [a, b] end)])
    |> List.flatten()
  end

  def compact(arr) do
    arr
    |> Enum.with_index()
    |> do_compact()
  end

  defp do_compact(arr) do
    {first_space, first_space_index} = arr |> Enum.find(fn {val, _} -> val === nil end)

    {first_char, first_char_index} =
      Enum.find(arr |> Enum.reverse(), fn {val, _} -> val !== nil end)

    if first_space_index > first_char_index do
      arr
    else
      arr =
        arr
        |> List.update_at(first_space_index, fn _ -> {first_char, first_space_index} end)
        |> List.update_at(first_char_index, fn _ -> {nil, first_char_index} end)

      do_compact(arr)
    end
  end

  def getResult(arr) do
    arr
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
  test "Day 9 - Part 1 - test data" do
    assert Main.run(true) == 1928
  end

  # @tag :skip
  test "Day 9 - Part 1 - real data" do
    assert Main.run(false) == 6_448_989_155_953
  end
end
