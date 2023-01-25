require "test_helper"
require "helpers/user_helper"

class NutrientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user
    @nutrient = FactoryBot.create(:nutrient)
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test "should get nutrient listing page" do
    get nutrients_url
    assert_response :success
  end

  test "should get new" do
    get new_nutrient_url
    assert_response :success
  end

  test "should create nutrient" do
    assert_difference("Nutrient.count") do
      post nutrients_url, params: { nutrient: { desc: @nutrient.desc, id: @nutrient.id, name: @nutrient.name, usda_ndb_num: @nutrient.usda_ndb_num } }
    end

    assert_redirected_to nutrient_url(Nutrient.last)
  end

  test "should show nutrient" do
    get nutrient_url(@nutrient)
    assert_response :success
  end

  test "should get edit" do
    get edit_nutrient_url(@nutrient)
    assert_response :success
  end

  test "should update nutrient" do
    patch nutrient_url(@nutrient), params: { nutrient: { desc: @nutrient.desc, id: @nutrient.id, name: @nutrient.name, usda_ndb_num: @nutrient.usda_ndb_num } }
    assert_redirected_to nutrient_url(@nutrient)
  end

  test "should destroy nutrient" do
    assert_difference("Nutrient.count", -1) do
      delete nutrient_url(@nutrient)
    end

    assert_redirected_to nutrients_url
  end
end
