defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "Adriano",
        password: "123456",
        nickname: "adrianoapj",
        email: "mrninhojr@gmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:ok)

      assert %{
        "account" => %{"balance" => "50.00", "id" => _id},
        "message" => "Balance updated successfully"
      } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit amount"}

      assert response == expected_response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
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

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid and there is enough money, make the withdraw", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:ok)

      assert %{
        "account" => %{"balance" => "0.00", "id" => _id},
        "message" => "Balance updated successfully"
      } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit amount"}

      assert response == expected_response
    end

    test "when there is not enough money, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "100.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => %{"balance" => ["is invalid"]}}

      assert response == expected_response
    end
  end

  describe "transaction/3" do
    setup %{conn: conn} do
      params = %{
        name: "Adriano",
        password: "123456",
        nickname: "adrianoapj",
        email: "mrninhojr@gmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: from}}} = Rocketpay.create_user(params)

      params = %{
        name: "Adriano 2",
        password: "123456",
        nickname: "adrianoapj2",
        email: "mrninhojr2@gmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: to}}} = Rocketpay.create_user(params)

      params = %{"id" => from, "value" => "50.00"}

      Rocketpay.deposit(params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, from: from, to: to}
    end

    test "when all params are valid and there is enough money in the from account, make the transaction", %{conn: conn, from: from, to: to} do
      params = %{"from" => from, "to" => to, "value" => "50.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> json_response(:ok)

      assert %{
        "message" => "Transaction executed successfully",
        "transaction" => %{
          "from_account" => %{
            "balance" => "0.00",
            "id" => _from
          },
          "to_account" => %{
            "balance" => "50.00",
            "id" => _to
          }
        }
      } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, from: from, to: to} do
      params = %{"from" => from, "to" => to, "value" => "banana"}

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit amount"}

      assert response == expected_response
    end

    test "when there is not enough money, returns an error", %{conn: conn, from: from, to: to} do
      params = %{"from" => from, "to" => to, "value" => "100.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => %{"balance" => ["is invalid"]}}

      assert response == expected_response
    end
  end
end
