require "test_helper"

class FoodsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    @food, @food2 = FactoryBot.create_list(:food, 2)
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Foods listing page' do
    get '/foods/'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    h1 = page.css('h1').first
    Rails.logger.debug("$$$ h1: #{h1.inspect}")
    assert h1.text.include?('Food Listing')
    # make a hash of all links on the page
    page_links = page.css('a')
    foods_count = Food.all.count
    assert_equal(4+foods_count, page_links.count)
    link_map = page_links.map{|a| [a.text, a['href']]}.to_h
    Rails.logger.debug("link_map: #{link_map.inspect}")
    assert_match("/foods/new",link_map['New food']) # has New Food Create link
    assert_match("/food_nutrients",link_map['Food Nutrients Listing']) # has Food Nutrients Listing link
    assert_match("/",link_map['Home']) # has Nutrients Listing link
    assert_match("/signout",link_map['Sign Out']) # has Sign Out link
  end

  test "should get new" do
    get new_food_url
    assert_response :success
  end

  test "should create food" do
    @new_food = FactoryBot.build(:food)
    assert_difference("Food.count") do
      post foods_url, params: { food: { desc: @new_food.desc, id: @new_food.id, name: @new_food.name, usda_fdc_id: @new_food.usda_fdc_id } }
    end

    assert_redirected_to food_url(Food.last)
  end

  test "should show food" do
    get food_url(@food)
    assert_response :success
  end

  test "should get edit" do
    get edit_food_url(@food)
    assert_response :success
  end

  test "should update food" do
    patch food_url(@food), params: { food: { desc: @food.desc, id: @food.id, name: @food.name, usda_fdc_id: @food.usda_fdc_id } }
    assert_redirected_to food_url(@food)
  end

  test "should destroy food" do
    assert_difference("Food.count", -1) do
      delete food_url(@food)
    end

    assert_redirected_to foods_url
  end
end
