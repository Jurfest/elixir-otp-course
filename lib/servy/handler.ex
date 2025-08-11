defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """
  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

  # __DIR__ is a Elixir macro that returns the directory of the file where the code is being executed.
  # It is useful for working with relative paths relative to the current file location.
  # @pages_path Path.expand("../../pages", __DIR__)
  # File.cwd! returns the current working directory. Mix always runs from the root project directory.
  # A function name ending with !, generally speaking, is a naming convention that conveys that
  # the function will raise an exception if it fails. In particular, calling File.cwd! is the
  # same as calling File.cwd but it raises an exception if for some reason there's a problem.
  @pages_path Path.expand("pages", File.cwd!())

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]
  # import SomeModule, except: :[some_function: 3]
  # import SomeModule, only: :functions
  # import SomeModule, only: :macros

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse()
    |> rewrite_path()
    |> log()
    |> route()
    |> track()
    |> put_content_length()
    |> format_response()
  end

  def route(%Conv{ method: "GET", path: "/snapshots" } = conv) do
    caller = self()

    spawn(fn -> send(caller, {:result, VideoCam.get_snapshot("cam-1")}) end)
    spawn(fn -> send(caller, {:result, VideoCam.get_snapshot("cam-2")}) end)
    spawn(fn -> send(caller, {:result, VideoCam.get_snapshot("cam-3")}) end)

    snapshot1 = receive do {:result, filename} -> filename end
    snapshot2 = receive do {:result, filename} -> filename end
    snapshot3 = receive do {:result, filename} -> filename end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect snapshots}
  end

  def route(%Conv{method: "GET", path: "/kaboom"}) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Awake!"}
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
  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    # This shortcut only works to modify values of keys that already exists in the map
    %{conv | status: 200, resp_body: "Bears, Tigers, Lions"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
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

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    # def route(conv, "GET", "/bears/" <> id) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    # def route(conv, "DELETE", "/bears/" <> id) do
    # %{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  # def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
  #   @pages_path
  #   |> Path.join(file <> ".html")
  #   |> File.read()
  #   |> handle_file(conv)
  # end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    html_file_path = Path.join(@pages_path, "#{name}.html")
    md_file_path = Path.join(@pages_path, "#{name}.md")

    cond do
      File.exists?(html_file_path) ->
        html_file_path
        |> File.read()
        |> handle_file(conv)

      File.exists?(md_file_path) ->
        md_file_path
        |> File.read()
        |> handle_file(conv)
        |> markdown_to_html

      true ->
        %{conv | status: 404, resp_body: "File not found!"}
    end
  end

  # Multi-clause functions
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    # Path.expand/2 combibes the relative path with the __DIR__ to generate the absolute path
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  # Default function clause has to be defined last and grouped together
  def route(%Conv{path: path} = conv) do
    # def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
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

  def put_content_length(%Conv{} = conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", byte_size(conv.resp_body))
    %{conv | resp_headers: headers}
  end

  # The Content-Length header must indicate the size of the body in bytes
  def format_response(%Conv{} = conv) do
    # The Content-Length header must indicate the size of the body in bytes.
    # Content-Length: #{String.length(conv.resp_body)}
    # HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    # Content-Type: text/html\r
    # Content-Type: #{conv.resp_headers["Content-Type"]}\r
    # Content-Length: #{conv.resp_headers["Content-Length"]}\r

    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn {key, value} ->
      "#{key}: #{value}\r"
    end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp markdown_to_html(%Conv{status: 200} = conv) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  defp markdown_to_html(%Conv{} = conv), do: conv
end
