defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  def index(conv) do
    bears_items =
      Wildthings.list_bears()
      # |> Enum.filter(fn b -> Bear.is_grizzly(b) end)
      |> Enum.filter(&Bear.is_grizzly(&1))
      |> Enum.sort(&Bear.order_asc_by_name(&1, &2))
      |> Enum.map(&bear_item(&1))
      |> Enum.join()

    %{conv | status: 200, resp_body: "<ul>#{bears_items}</ul>"}
  end

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  # Take the entire params map and the do pattern matching gives more flexibility
  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | status: 200, resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>"}
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{
      conv
      | status: 201,
        resp_body: "Create a #{type} bear named #{name}!"
    }
  end
end
