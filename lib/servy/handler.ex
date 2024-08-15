defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log
    |> route()
    |> track()
    |> format_response()
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def log(conv), do: IO.inspect(conv)

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

  # Transform parsed map into a new map | one arity call three arity function - function clauses
  # def route(conv) do
  #   # if conv.path == "/wildthings" do
  #   #   # Map.put(conv, :new_field, "Item")
  #   #   # Conversation between browser and server
  #   #   %{conv | resp_body: "Bears, Tigers, Lions"}
  #   # else
  #   #   %{conv | resp_body: "Teddy, Smokey, Paddington"}
  #   # end

  #   route(conv, conv.method, conv.path)
  # end

  # Example without map pattern matching | simple pattern matching - it's a matter of preference
  # to choose between this different ways of implementation
  # def route(conv, "GET", "/wildthings") do
  #   %{conv | status: 200, resp_body: "Bears, Tigers, Lions"}
  # end

  # map pattern matching
  def route(%{method: "GET", path: "/wildthings"} = conv) do
    # This shortcut only works to modify values of keys that already exists in the map
    %{conv | status: 200, resp_body: "Bears, Tigers, Lions"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    # def route(conv, "GET", "/bears/" <> id) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    # def route(conv, "DELETE", "/bears/" <> id) do
    %{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

  # Default function clause has to be defined last and grouped together
  def route(%{path: path} = conv) do
    # def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts("Warning: #{path} is on the loose!")
    conv
  end

  def track(conv), do: conv

  # The Content-Length header must indicate the size of the body in bytes
  def format_response(conv) do
    # The Content-Length header must indicate the size of the body in bytes.
    # Content-Length: #{String.length(conv.resp_body)}

    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  # Private functions can only be accessed inside its module
  defp status_reason(code) do
    %{
      200 => "Ok",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

# TODO: - Pass to test and clean below requests

# /wildthings
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# /bears
request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# /bigfoot
request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# bears/1
request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# delete
request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# /wildlife
request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """
