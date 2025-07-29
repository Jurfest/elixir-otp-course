defmodule Servy.BearControllerTest do
  use ExUnit.Case
  alias Servy.{BearController, Conv}

  test "index returns 200 status and sorted bears list" do
    conv = %Conv{method: "GET", path: "/bears"}

    result = BearController.index(conv)

    assert result.status == 200
    assert String.contains?(result.resp_body, "Brutus")
    assert String.contains?(result.resp_body, "Teddy")
  end

  test "show returns 200 status and specific bear" do
    conv = %Conv{method: "GET", path: "/bears/1"}

    result = BearController.show(conv, %{"id" => "1"})

    assert result.status == 200
    assert String.contains?(result.resp_body, "Teddy")
  end

  test "create returns 201 status and confirmation message" do
    conv = %Conv{method: "POST", path: "/bears"}
    params = %{"name" => "Baloo", "type" => "Brown"}

    result = BearController.create(conv, params)

    assert result.status == 201
    assert result.resp_body == "Created a Brown bear named Baloo!"
  end
end
