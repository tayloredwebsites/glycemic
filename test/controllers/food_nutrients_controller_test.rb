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
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Nutrients of Food Listing", 'Nutrients of Food Listing', "for food: #{@food.name}")
    # confirm we are starting with 2 total food nutrients for this food
    food_nutrients_count = FoodNutrient.where(food_id: @food.id).count
    assert_equal(2, food_nutrients_count)
    linksH = get_links_hashes(page)
    # make sure we have links for the header, two for each nutrient, and one at the bottom
    assert_equal(5+food_nutrients_count*2+1, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(linksH)
    # assert_gets_page("/signout", 'Log in')
    @food_nutrients.each do |fn|
      assert_link_has(linksH, {
        :link_text => "Edit",
        :link_url => "/food_nutrients/#{fn.id}/edit",
        :page_title => "Food Nutrient Edit Page",
        :page_subtitle => "Food Nutrient Edit Page",
        :page_subtitle2 => "for food: #{@food.name}",
      })
      assert_link_has(linksH, {
        :link_text => "Delete",
        :link_url => "/food_nutrients/#{fn.id}",
        # ToDo: validate the "Are you sure?" alert
        # ToDo: validate the delete page is linked to properly
      })
    end
    assert_link_has(linksH, {
      :link_text => "New food nutrient",
      :link_url => "/food_nutrients/new?food_id=#{@food.id}",
      :page_title => "New Food Nutrient",
      :page_subtitle => "New Food Nutrient",
      :page_subtitle2 => "for food: #{@food.name}",
    })

  end

  test "should get new" do
    get "/food_nutrients/new?food_id=#{@food.id}"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "New Food Nutrient", "New Food Nutrient", "for food: #{@food.name}")
    linksH = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(5, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(linksH)

    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")
    page = Nokogiri::HTML.fragment(response.body)
    # confirm that the only option displayed is the third nutrient, which has not been assigned to this food yet.
    assert_select_has(page, 'food_nutrient_nutrient_id', {
      :options_count => 1,
      :selected_count => 0,
      :displayed_option => @nutrient3.name,
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

  test "should view food_nutrients for " do
    get food_nutrient_url(@food_nutrient)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "'#{@food.name}' Nutrient View Page", 'for food nutrient', @food_nutrient.nutrient.name)
    # confirm we are starting with 2 total food nutrients for this food
    # food_nutrients_count = FoodNutrient.where(food_id: @food.id).count
    # assert_equal(2, food_nutrients_count)
    linksH = get_links_hashes(page)
    # make sure we have 5 links for the header, two for each food_nutrient action (edit, delete), and the 'new' action at the bottom
    assert_equal(5+3, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(linksH)
    assert_link_has(linksH, {
      :link_text => "New nutrient for #{@food.name}",
      :link_url => "/food_nutrients/new?food_id=#{@food.id}",
      :page_title => "New Food Nutrient",
      :page_subtitle => "for food:",
      :page_subtitle2 => @food.name,
    })
    assert_link_has(linksH, {
      :link_text => "Edit this nutrient for #{@food.name}",
      :link_url => "/food_nutrients/#{@food_nutrient.id}/edit",
      :page_title => "Food Nutrient Edit Page",
      :page_subtitle => "for food: #{@food.name}",
      :page_subtitle2 => "and nutrient: #{@food_nutrient.nutrient.name}",
      :debugging => true,
    })
    assert_link_has(linksH, {
      :link_text => "Remove this nutrient from #{@food.name}",
      :link_url => "/food_nutrients/#{@food_nutrient.id}",
      # ToDo: validate the "Are you sure?" alert
      # ToDo: validate the delete page is linked to properly
    })
  
    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")

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
