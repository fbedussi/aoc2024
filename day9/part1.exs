defmodule InputHelpers do
  def parse(isTest) do
    filePath = if isTest, do: "test-data.txt", else: "data.txt"

    {:ok, rawData} = File.read(filePath)

    rawData
    |> String.split("\n", trim: true)
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.map(fn line -> line |> String.split("", trim: true) end)
    |> hd()

    # |> length()
    # |> IO.inspect(label: "length")
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
      |> Enum.map(fn {val, i} ->
        String.pad_leading("", String.to_integer(val), Integer.to_string(i))
      end)

    spaces =
      arr
      |> tl()
      |> Enum.take_every(2)
      |> Enum.map(fn val ->
        String.pad_leading("", String.to_integer(val), ".")
      end)

    Enum.concat([[blocksH], List.zip([spaces, blocksT]) |> Enum.map(fn {a, b} -> [a, b] end)])
    |> List.flatten()
    |> Enum.join()
  end

  def compact(str) do
    arr =
      str
      |> String.split("", trim: true)

    arrReversed =
      arr
      |> Enum.reverse()

    compact(arr, arrReversed, [])
    |> Enum.reverse()
    |> Enum.join()
  end

  defp compact([h | t], [hr | tr], result) do
    if Enum.all?(t, fn i -> i === "." end) do
      result
    else
      compact(t, tr, [hr | [h | result]])
    end
  end

  def getResult(str) do
    1
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

  @tag :skip
  test "convert" do
    assert Helpers.convert("12345") == "0..111....22222"
  end

  @tag :skip
  test "compact" do
    assert Helpers.compact("0..111....22222") == "022111222......"
  end

  @tag :skip
  test "getResult" do
    assert Helpers.getResult("0099811188827773336446555566..............") == 1928
  end

  # @tag :skip
  test "Day 9 - Part 1 - test data" do
    assert Main.run(true) == 1928
  end

  # @tag :skip
  test "Day 9 - Part 1 - real data" do
    assert Main.run(false) == 394
  end
end
