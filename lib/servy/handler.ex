defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  # __DIR__ is a Elixir macro that returns the directory of the file where the code is being executed.
  # It is useful for working with relative paths relative to the current file location.
  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> format_response()
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

  def route(%{method: "GET", path: "/bears/new"} = conv) do
    file =
      @pages_path
      |> Path.join("form.html")

    case File.read(file) do
      {:ok, content} ->
        %{conv | status: 200, resp_body: content}

      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "File not found!"}

      {:error, reason} ->
        %{conv | status: 500, resp_body: "File error #{reason}"}
    end
  end

  def route(%{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  # Multi-clause functions
  def route(%{method: "GET", path: "/about"} = conv) do
    # Path.expand/2 combibes the relative path with the __DIR__ to generate the absolute path
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
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

  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error #{reason}"}
  end

  # Case expression - it's a design decision, depending on situation and preference
  # def route(%{method: "GET", path: "/about"} = conv) do
  #   # __DIR__ is a Elixir macro that returns the directory of the file where the code is being executed.
  #   # It is useful for working with relative paths relative to the current file location.
  #   # Path.expand/2 combibes the relative path with the __DIR__ to generate the absolute path
  #   file = @pages_path
  #   |> Path.join("about.html")
  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | status: 200, resp_body: content}

  #     {:error, :enoent} ->
  #       %{conv | status: 404, resp_body: "File not found!"}

  #     {:error, reason} ->
  #       %{conv | status: 500, resp_body: "File error #{reason}"}
  #   end
  # end

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

# /bears?id=1 - to be rewrite to /bears/1 (juice up a page's SEO)
request = """
GET /bears?id=1 HTTP/1.1
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

# /about
request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# /bears/new
request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# /pages/contact
request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)
