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
    @food_nutrients = [@food_nutrient, @food_nutrient2]
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Nutrients of a Food listing page' do
    get "/nutrients_of_food/#{@food.id}"
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    h2 = page.css('h2').first
    Rails.logger.debug("$$$ h2: #{h2.inspect}")
    assert h2.text.include?('Nutrients of Food Listing')
    assert h2.text.include?("for food: #{@food.name}")
    # make a hash of all links on the page
    page_links = page.css('a')
    title_map = page_links.map{|a| [a.text, a['href']]}.to_h
    Rails.logger.debug("title_map: #{title_map.inspect}")
    link_map = page_links.map{|a| [ a['href'], a.text]}.to_h
    Rails.logger.debug("link_map: #{link_map.inspect}")
    food_nutrients_count = FoodNutrient.all.count
    assert_equal(2, food_nutrients_count)
    # make sure we have links for the header, two for each nutrient, and one at the bottom
    assert_equal(5+food_nutrients_count*2+1, page_links.count)
    # make sure that we have the correct links on the page
    assert_match("/nutrients_of_food/#{@food.id}",title_map["#{@food.name} Nutrients"])
    assert_match("/foods",title_map["Foods Listing"])
    assert_match("/nutrients",title_map["Nutrients Listing"])
    assert_match("/",title_map["Home"])
    assert_match("/signout",title_map["Sign Out"])
    @food_nutrients.each do |fn|
      assert_match("Edit",link_map["/food_nutrients/#{fn.id}/edit"])
      assert_match("Delete",link_map["/food_nutrients/#{fn.id}"])
    end
    assert_match("/food_nutrients/new?food_id=#{@food.id}",title_map["New food nutrient"])
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
