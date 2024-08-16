defmodule Servy.Conv do
  # A struct instance is just a special kind of map with a fix set of
  # keys and default values.
  # It can be thought also as a typed map - it brings type safety
  defstruct method: "", path: "", resp_body: "", status: nil

  # Keyword lists aren't yet another collection, but rather a tasty mashup of lists and tuples.
  # [ {:method, ""}, {:path, ""}, {:resp_body, ""}, {:status, nil} ]

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
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
