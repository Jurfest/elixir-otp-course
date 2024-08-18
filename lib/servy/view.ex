defmodule Servy.View do
  @templates_path Path.expand("templates", File.cwd!())

  def render(conv, template, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(template)
      # eval_file isn't a good choice for high-performance web server - function_from_file is better
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end
end
