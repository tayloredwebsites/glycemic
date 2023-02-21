require "test_helper"
require "helpers/nokogiri_helper"

class FoodNutrientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    @food = FactoryBot.create(:food)
    @nutrient, @nutrient2, @nutrient3 = FactoryBot.create_list(:nutrient, 3)
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
    assert_match("#{@food.name} Nutrients",link_map["/nutrients_of_food/#{@food.id}"])
    assert_gets_page("/nutrients_of_food/#{@food.id}", 'Nutrients of Food Listing', "for food: #{@food.name}")
    assert_match("/foods",title_map["Foods Listing"])
    assert_gets_page("/foods", 'Foods Listing')
    assert_match("/nutrients",title_map["Nutrients Listing"])
    assert_gets_page("/nutrients", 'Nutrients Listing')
    assert_match("/",title_map["Home"])
    assert_gets_page("/", 'Home')
    assert_match("/signout",title_map["Sign Out"])
    # assert_gets_page("/signout", 'Log in')
    @food_nutrients.each do |fn|
      assert_match("Edit",link_map["/food_nutrients/#{fn.id}/edit"])
      assert_gets_page("/food_nutrients/#{fn.id}/edit", 'Food Nutrient Edit Page', "for food: #{@food.name}")
      assert_match("Delete",link_map["/food_nutrients/#{fn.id}"])
      #ToDo: validation of delete involves rest DELETE, and js popup. test in systems tests 
    end
    assert_match("",title_map["New food nutrient"])
    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")
  end

  test "should get new" do
    get "/food_nutrients/new?food_id=#{@food.id}"
    assert_response :success
    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")
    page = Nokogiri::HTML.fragment(response.body)
    # confirm that the only option displayed is the third nutrient, which has not been assigned to this food yet.
    assert_select_has(page, 'food_nutrient_nutrient_id', {
      :options_count => 1,
      :selected_count => 0,
      :displayed_option => @nutrient3.name,
      # :selected => [
      #   "value1" => "text1",
      # ],
      # :match_by_value => true,
      # :match_by_text => true,
      # :debugging => true,
    })
    # confirm all appropriate fields exist
    assert_equal(1, page.css('input#food_nutrient_portion').count)
    Rails.logger.debug("$$$ FoodNutrient::GRAM: #{FoodNutrient::GRAM}")
    assert_select_has(page, 'portion_unit', {
      :displayed_option => FoodNutrient::GRAM,
    })
    assert_equal(1, page.css('input#food_nutrient_amount').count)
    assert_select_has(page, 'amount_unit', {
      :displayed_option => FoodNutrient::GRAM,
    })
    assert_equal(1, page.css('textarea#food_nutrient_desc').count)
    assert_equal(1, page.css("input[type='submit'][value='Create Food nutrient']").count)
    assert_equal(1, page.css("form[action='/food_nutrients']").count)
    # confirm hidden input field for food_id exists and is the correct value
    food_id_node = page.css("input#food_nutrient_food_id")
    Rails.logger.debug("$$$ food_id_node: #{food_id_node}")
    assert_equal(1, food_id_node.count)
    Rails.logger.debug("$$$ food_id_node['value']: #{food_id_node.first['value']}")
    assert_equal(@food.id.to_s, food_id_node.first['value'])
  end

  test "should create food_nutrient" do
    @new_food_nutrient = FactoryBot.build(:food_nutrient)
    Rails.logger.debug("*** food id: #{@food.id}")
    Rails.logger.debug("*** nutrient id: #{@nutrient.id}")
    assert_difference("FoodNutrient.count", 1, "a Food Nutrient should be created") do
      post food_nutrients_url, params: {
        food_nutrient: {
          food_id: @food.id,
          nutrient_id: @nutrient.id,
          amount: @new_food_nutrient.amount,
          amount_unit: @new_food_nutrient.amount_unit,
          avg_rec_id: @new_food_nutrient.avg_rec_id,
          desc: @new_food_nutrient.desc,
          portion: @new_food_nutrient.portion,
          portion_unit: @new_food_nutrient.portion_unit,
          study: @new_food_nutrient.study,
          study_weight: @new_food_nutrient.study_weight
        }
      }
    end

    assert_redirected_to food_nutrient_url(FoodNutrient.last)
  end

  test "should show food_nutrients for " do
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
