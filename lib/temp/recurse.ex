defmodule Recurse do
  def sum([head | tail], total) do
    sum(tail, total + head)
  end

  def sum([], total), do: total

  # def triple([head | tail]) do
  #   [head * 3 | triple(tail)]
  # end

  # def triple([]), do: []

  def triple(list) do
    triple(list, [])
  end

  defp triple([head | tail], current_list) do
    triple(tail, [head * 3 | current_list])
  end

  defp triple([], current_list) do
    current_list |> Enum.reverse()
  end
end

IO.puts(Recurse.sum([1, 2, 3, 4, 5], 0))
IO.inspect(Recurse.triple([1, 2, 3, 4, 5]))
