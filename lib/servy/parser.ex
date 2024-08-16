defmodule Servy.Parser do

  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  # Transform the request string into a key-value pair, i.e., a map (which corresponds to JS object)
  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # Last expression of the function is returned automatically
    %Conv{
      method: method,
      path: path,
    }
  end
end
