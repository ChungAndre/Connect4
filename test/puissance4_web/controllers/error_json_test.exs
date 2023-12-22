defmodule Puissance4Web.ErrorJSONTest do
  use Puissance4Web.ConnCase, async: true

  test "renders 404" do
    assert Puissance4Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Puissance4Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
