defmodule RocketpayWeb.AccountsViewTest do
  use RocketpayWeb.ConnCase, async: true

  import Phoenix.View

  alias Rocketpay.{User}
  alias RocketpayWeb.AccountsView

  test "renders update.json" do
    params = %{
      name: "Adriano",
      password: "123456",
      nickname: "adrianoapj",
      email: "mrninhojr@gmail.com",
      age: 18
    }

    {:ok, %User{account: account}} = Rocketpay.create_user(params)

    response = render(AccountsView, "update.json", %{account: account})

    expected_response = %{
      message: "Balance updated successfully",
      account: %{
        balance: Decimal.new("0.00"),
        id: account.id
      }
    }

    assert expected_response == response
  end
end
