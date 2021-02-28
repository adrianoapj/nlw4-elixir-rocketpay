defmodule Rocketpay.Users.DepositTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{Account, User}
  alias Rocketpay.Accounts.Deposit

  describe "call/1" do
    setup do
      params = %{
        name: "Adriano",
        password: "123456",
        nickname: "adrianoapj",
        email: "mrninhojr@gmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      {:ok, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "50.00"}

      Deposit.call(params)
      %Account{id: id, balance: balance} = Repo.get(Account, account_id)

      expected_response = %Account{id: account_id, balance: Decimal.new("50.00")}

      assert expected_response == %Account{id: id, balance: balance}
    end

    test "when value is invalid, do not make the deposit", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "banana"}

      Deposit.call(params)
      %Account{id: id, balance: balance} = Repo.get(Account, account_id)

      expected_response = %Account{id: account_id, balance: Decimal.new("0.00")}

      assert expected_response == %Account{id: id, balance: balance}
    end
  end
end
