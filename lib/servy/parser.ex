defmodule Servy.Parser do
  # Transform the request string into a key-value pair, i.e., a map (which corresponds to JS object)
  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    # Last expression of the function is returned automatically
    %{
      method: method,
      path: path,
      resp_body: "",
      status: nil
    }
  end
end
