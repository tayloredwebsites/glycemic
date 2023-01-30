require "test_helper"

class FoodNutrientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    @food = FactoryBot.create(:food)
    @nutrient, @nutrient2 = FactoryBot.create_list(:nutrient, 2)
    @food_nutrient = FactoryBot.create(:food_nutrient, food: @food, nutrient: @nutrient)
    @food_nutrient2 = FactoryBot.create(:food_nutrient, food: @food, nutrient: @nutrient2)
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Foods Nutrients listing page' do
    get '/food_nutrients/'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    h1 = page.css('h1').first
    Rails.logger.debug("$$$ h1: #{h1.inspect}")
    assert h1.text.include?('Food Nutrients Listing')
    # make a hash of all links on the page
    page_links = page.css('a')
    food_nutrients_count = FoodNutrient.all.count
    assert_equal(4+food_nutrients_count, page_links.count)
    link_map = page_links.map{|a| [a.text, a['href']]}.to_h
    Rails.logger.debug("link_map: #{link_map.inspect}")
    assert_match("/food_nutrients/new",link_map['New food nutrient']) # has New Food Nutrients link
    assert_match("/foods",link_map['Foods Listing']) # has Foods Listing link
    assert_match("/",link_map['Home']) # has Nutrients Listing link
    assert_match("/signout",link_map['Sign Out']) # has Sign Out link
  end

  test "should get new" do
    get new_food_nutrient_url
    assert_response :success
  end

  test "should create food_nutrient" do
    @new_food_nutrient = FactoryBot.build(:food_nutrient)
    Rails.logger.debug("*** food id: #{@food.id}")
    Rails.logger.debug("*** nutrient id: #{@nutrient.id}")
    assert_difference("FoodNutrient.count") do
      post food_nutrients_url, params: { food_nutrient: { food_id: @food.id, nutrient_id: @nutrient.id, amount: @new_food_nutrient.amount, amount_unit: @new_food_nutrient.amount_unit, avg_rec_id: @new_food_nutrient.avg_rec_id, desc: @new_food_nutrient.desc, portion: @new_food_nutrient.portion, portion_unit: @new_food_nutrient.portion_unit, study: @new_food_nutrient.study, study_weight: @new_food_nutrient.study_weight } }
    end

    assert_redirected_to food_nutrient_url(FoodNutrient.last)
  end

  test "should show food_nutrient" do
    get food_nutrient_url(@food_nutrient)
    assert_response :success
  end

  test "should get edit" do
    get edit_food_nutrient_url(@food_nutrient)
    assert_response :success
  end

  test "should update food_nutrient" do
    patch food_nutrient_url(@food_nutrient), params: { food_nutrient: { amount: @food_nutrient.amount, amount_unit: @food_nutrient.amount_unit, avg_rec_id: @food_nutrient.avg_rec_id, desc: @food_nutrient.desc, food_id: @food_nutrient.food_id, id: @food_nutrient.id, nutrient_id: @food_nutrient.nutrient_id, portion: @food_nutrient.portion, portion_unit: @food_nutrient.portion_unit, study: @food_nutrient.study, study_weight: @food_nutrient.study_weight } }
    assert_redirected_to food_nutrient_url(@food_nutrient)
  end

  test "should destroy food_nutrient" do
    assert_difference("FoodNutrient.count", -1) do
      delete food_nutrient_url(@food_nutrient)
    end

    assert_redirected_to food_nutrients_url
  end
end
