defmodule Servy.Parser do
  # alias Servy.Conv, as: Conv
  alias Servy.Conv

  # Transform the request string into a key-value pair, i.e., a map (which corresponds to JS object)

  # The parse function takes a raw HTTP request string and converts it into a Conv
  # struct that represents the conversation/request in a structured format
  def parse(request) do
    # parts: 2 option guarantee that String.split/3 always returns two parts
    [top, params_string] = String.split(request, "\r\n\r\n", parts: 2)
    [request_line | header_lines] = String.split(top, "\r\n")
    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    # Last expression of the function is returned automatically
    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  # def parse_headers([head | tail], headers) do
  #   [key, value] = String.split(head, ":")
  #   headers = Map.put(headers, key, String.trim(value))

  #   parse_headers(tail, headers)
  # end

  # def parse_headers([], headers), do: headers

  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn line, headers_so_far ->
      [key, value] = String.split(line, ": ")
      Map.put(headers_so_far, key, value)
    end)
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with corresponding keys and values.

  ## Examples
      iex> params_string = "name=Baloo&type=Brown"
      iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
      %{"name" => "Baloo", "type" => "Brown"}
      iex> Servy.Parser.parse_params("multipart/form-data", params_string)
      %{}
  """
  @spec parse_params(String.t(), String.t()) :: map()
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim()
    |> URI.decode_query()
  end

  def parse_params("application/json", params_string) do
    params_string
    |> Poison.Parser.parse!(%{})
  end

  def parse_params(_, _), do: %{}
end
