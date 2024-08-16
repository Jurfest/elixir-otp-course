defmodule Servy.Parser do

  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  # Transform the request string into a key-value pair, i.e., a map (which corresponds to JS object)
  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")
    [request_line | _header_lines] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")

    params = parse_params(params_string)

    # Last expression of the function is returned automatically
    %Conv{
      method: method,
      path: path,
      params: params
    }
  end

  def parse_params(params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()

  end
end
