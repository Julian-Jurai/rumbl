defmodule Rumbl.AccountsTest do 
  use Rumbl.DataCase, async: true

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  describe "register_user/1" do
    @valid_attrs %{ 
      name: "User",
      username: "eva",
      password: "secret12345678",
    }

    @invalid_attrs %{}


    test "with valid data inserts user" do  
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
      assert user.name == "User"
      assert user.username == "eva"
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data does not insert user" do 
      assert {:error, _changeset} = Accounts.register_user(@invalid_attrs)
      assert Accounts.list_users == []
    end

    test "enforce unqiue usernames" do 
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)

      assert %{ username: ["has already been taken"] } = errors_on(changeset)

      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "requires password to be at least 6 chars long" do 
      attrs = Map.put(@valid_attrs, :password, "12345")

      {:error, changeset} = Accounts.register_user(attrs)

      assert %{ password: ["should be at least 6 character(s)"]} = errors_on(changeset)
      assert Accounts.list_users() == []
    end
  end

  describe "authenticate_by_username_and_pass/2" do 
    @pass "123456"

    setup do 
      {:ok, user: user_fixture(password: @pass)}
    end


    test "returns user with correct password", %{user: user} do 
      IO.puts(inspect(user))
      # assert {:ok, auth_user} = Accounts.authenticate_by_username_and_pass(user.username, @pass)
      # assert auth_user.id == user.id
    end
  end
end