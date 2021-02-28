defmodule Rocketpay.Users.WithdrawTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{Account, User}
  alias Rocketpay.Accounts.Withdraw

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

      params = %{"id" => account_id, "value" => "50.00"}

      Rocketpay.deposit(params)

      {:ok, account_id: account_id}
    end

    test "when all params are valid, make the withdraw", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "50.00"}

      Withdraw.call(params)
      %Account{id: id, balance: balance} = Repo.get(Account, account_id)

      expected_response = %Account{id: account_id, balance: Decimal.new("0.00")}

      assert expected_response == %Account{id: id, balance: balance}
    end

    test "when value is invalid, do not make the withdraw", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "banana"}

      Withdraw.call(params)
      %Account{id: id, balance: balance} = Repo.get(Account, account_id)

      expected_response = %Account{id: account_id, balance: Decimal.new("50.00")}

      assert expected_response == %Account{id: id, balance: balance}
    end

    test "when there is not enough money, do not make the withdraw", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "100.00"}

      Withdraw.call(params)
      %Account{id: id, balance: balance} = Repo.get(Account, account_id)

      expected_response = %Account{id: account_id, balance: Decimal.new("50.00")}

      assert expected_response == %Account{id: id, balance: balance}
    end
  end
end
