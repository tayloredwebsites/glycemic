require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = FactoryBot.create(:user)
    sign_in(@user)
  end

  # called after every single test
  teardown do
  end

  test "visiting the home page works for signed in user" do
    # skip("Use Controller Tests. They are slow.  Note: save_and_open_page hangs up test.")
    visit home_index_url
    # save_and_open_page
    assert_selector "h1", text: "Home#index"
  end

end
