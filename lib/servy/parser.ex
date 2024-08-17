defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  # Transform the request string into a key-value pair, i.e., a map (which corresponds to JS object)
  def parse(request) do
    # parts: 2 option guarantee that String.split/3 always returns two parts
    [top, params_string] = String.split(request, "\n\n", parts: 2)
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    # Last expression of the function is returned automatically
    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ":")
    headers = Map.put(headers, key, String.trim(value))

    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
