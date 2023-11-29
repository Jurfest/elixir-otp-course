defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse()
    |> log
    |> route()
    |> format_response()
  end

  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: ""}
  end

  def route(conv) do
    # if conv.path == "/wildthings" do
    #   # Map.put(conv, :new_field, "Item")
    #   %{conv | resp_body: "Bears, Tigers, Lions"}
    # else
    #   %{conv | resp_body: "Teddy, Smokey, Paddington"}
    # end
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | resp_body: "Bears, Tigers, Lions"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | resp_body: "Teddy, Smokey, Paddington"}
  end

  # The Content-Length header must indicate the size of the body in bytes
  def format_response(conv) do
    # Content-Length: #{String.length(conv.resp_body)}

    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)
