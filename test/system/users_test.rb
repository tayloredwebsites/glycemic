# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

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
    visit home_index_path
    # save_and_open_page
    assert_selector "h1", text: "Home#index"
  end

end
