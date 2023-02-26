require "test_helper"
require "helpers/nokogiri_helper"

class FoodsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    @food1, @food2 = FactoryBot.create_list(:food, 2)
    @foods = [@food1, @food2]
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Foods listing page' do
    get '/foods/'
    assert_response 200
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Foods Listing")
    linksH = get_links_hashes(page)
    # make sure we have links for the header, two for each food, and one at the bottom
    foods_count = Food.all.count
    assert_equal(5+foods_count*3+1, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, linksH)

    @foods.each do |fn|
      assert_link_has(linksH, {
        :link_text => "Edit",
        :link_url => "/foods/#{fn.id}/edit",
        :page_title => "Edit Food Page",
        :page_subtitle => "for food: #{fn.name}",
      })
      assert_link_has(linksH, {
        :link_text => "Nutrients",
        :link_url => "/nutrients_of_food/#{fn.id}",
        :page_title => "Nutrients of Food Listing",
        :page_subtitle => "for food: #{fn.name}",
      })
      assert_link_has(linksH, {
        :link_text => "Delete",
        :link_url => "/foods/#{fn.id}",
        # ToDo: validate the "Are you sure?" alert
        # ToDo: validate the delete page is linked to properly
      })
    end
    assert_link_has(linksH, {
      :link_text => "New Food",
      :link_url => "/foods/new",
      :page_title => "New Food Page",
      :page_subtitle => "New Food Page",
    })

  end

  test "should get new" do
    get "/foods/new"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "New Food Page", "New Food Page")
    linksH = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(5, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, linksH)

    # confirm all appropriate fields exist
    assert_equal(1, page.css("form[action='/foods']").count)
    assert_equal(1, page.css('input#food_name').count)
    assert_equal(1, page.css('textarea#food_desc').count)
    assert_equal(1, page.css('input#food_usda_fdc_id').count)
    assert_equal(1, page.css("input[type='submit'][value='Create Food']").count)

  end

  test "should create food" do
    @new_food = FactoryBot.build(:food)
    assert_difference("Food.count", 1, "a Food should be created") do
      post foods_url, params: {
        food: {
          # id: @new_food.id,
          name: @new_food.name,
          desc: @new_food.desc,
          usda_fdc_id: @new_food.usda_fdc_id,
        }
      }
    end
    assert_redirected_to food_url(Food.last)
  end

  test "should show food" do
    # ToDo: enhance this test if and when show page is enhanced
    get food_url(@food1)
    assert_response :success
  end

  test "should get edit" do
    get edit_food_url(@food1)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Edit Food Page", "Edit Food Page", "for food: #{@food1.name}")
    linksH = get_links_hashes(page)
    # make sure we have links for the header plus 2 extra ones below
    assert_equal(5+2, linksH[:count])
    # make sure that we have the correct links on the page
    @food = @food1.clone # 'assert_page_headers' uses @food to determine if 'Food' Nutrients link should be dim or not.
    assert_page_headers(page, linksH)

    assert_link_has(linksH, {
      :link_text => "New Food",
      :link_url => "/foods/new",
      :page_title => "New Food Page",
      :page_subtitle => "New Food Page",
    })
    assert_link_has(linksH, {
      :link_text => "Delete this food",
      :link_url => "/foods/#{@food1.id}",
      # ToDo: validate the "Are you sure?" alert
      # ToDo: validate the delete page is linked to properly
    })

  end

  test "should update food" do
    # save off the original state of the food nutrient
    @changed_food = @food1.dup

    # put in some changes
    # @changed_food.id = -1  # this is the record to be updated
    @changed_food.name = "A new name for the food"
    @changed_food.desc = 'has been changed'
    @changed_food.usda_fdc_id = 75
    # @changed_food.created_at = Date.tomorrow # should not be a permitted param
    # @changed_changed_foodnutrient.updated_at = Date.tomorrow # should not be a permitted param

    Rails.logger.debug("$$$ @food1: #{@food1.inspect}")
    Rails.logger.debug("$$$ @changed_food: #{@changed_food.inspect}")

    # confirm no new records are created from this update
    assert_difference("Food.count", 0, "No Foods should be created") do
      # update the food_nutrient in the controller update action
      patch food_url(@food1), params: {
        food: {
          # id: @food_nutrient.id, # note: this is passed in params
          name: @changed_food.name,
          desc: @changed_food.desc,
          usda_fdc_id: @changed_food.usda_fdc_id,
        }
      }
    end

    # confirm we are at the food nutrient view page
    assert_redirected_to food_url(@food1)

    @updated_food = Food.find_by(id: @food1.id)

    Rails.logger.debug("$$$ @updated_food: #{@updated_food.inspect}")

    assert_equal(@changed_food.name, @updated_food.name)
    assert_equal(@changed_food.desc, @updated_food.desc)
    assert_equal(@changed_food.usda_fdc_id, @updated_food.usda_fdc_id)
    
  end

  test "should destroy food" do
    assert_difference("Food.count", -1) do
      delete food_url(@food1)
    end

    assert_redirected_to foods_url
  end
end
