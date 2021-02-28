defmodule RocketpayWeb.WelcomeControllerTest do
  use RocketpayWeb.ConnCase, async: true

  describe "index/2" do
    test "when the file exists, return the sum of the numbers", %{conn: conn} do
      filename = "numbers"

      response =
        conn
        |> get(Routes.welcome_path(conn, :index, filename))
        |> json_response(:ok)

      assert %{"message" => "Welcome to Rocketpay API. Here is your number 37"} = response
    end
  end
end
