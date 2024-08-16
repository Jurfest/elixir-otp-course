defmodule Servy.Plugins do
  # The Logger module uses Elixir macros, so it has to be required, for the macros to do their magic
  require Logger

  @doc "Los 404 requests"
  def track(%{status: 404, path: path} = conv) do
    IO.puts("Warning: #{path} is on the loose!")
    conv
  end

  def track(conv), do: conv

  # /bears?id=1
  # def rewrite_path(%{path: "/bears?id=" <> id} = conv) do
  #   %{conv | path: "/bears/#{id}"}
  # end

  # def rewrite_path(conv), do: conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # Generic rewrite function using regular expresion
  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def log(conv), do: IO.inspect(conv)

  # def log(conv) do
  #   Logger.info(conv)
  #   # Logger.warn("Do we have a problem, Houston?")
  #   # Logger.error("Danger, Will Robinson!")
  #   conv
  # end

  def emojify(%{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = emojies <> "\n" <> conv.resp_body <> "\n" <> emojies

    %{conv | resp_body: body}
  end

  def emojify(conv), do: conv
end
