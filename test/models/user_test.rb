require "test_helper"

class UserTest < ActiveSupport::TestCase

  setup do
    @user = FactoryBot.create("user")
  end

  test "invalid user when email blank" do
    @user.email = ""
    assert_not(@user.valid?)
  end

  test "invalid username when username blank" do
    skip("This could be done if required and part of sign up")
    @user.username = ""
    assert_not(@user.valid?)
  end

  test "invalid user when full_name blank" do
    skip("This could be done if fullname is part of sign up")
    @user.full_name = ""
    assert_not(@user.valid?)
  end

  test "valid user when password >= 8 characters" do
    @user.password = "12345678"
    @user.password_confirmation = "12345678"
    assert(@user.valid?)
  end

  test "invalid user when password < 8 characters" do
    @user.password = "1234567"
    @user.password_confirmation = "1234567"
    assert_not(@user.valid?)
  end

  test "invalid user when password mismatch" do
    @user.password = "1234567"
    @user.password_confirmation = "1234568"
    assert_not(@user.valid?)
  end

  test "invalid user when password blank" do
    @user.password = ""
    @user.password_confirmation = ""
    assert_not(@user.valid?)
  end

end
