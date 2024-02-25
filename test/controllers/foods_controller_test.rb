# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require "test_helper"
require "helpers/nokogiri_helper"
require "helpers/lookup_table_test"

class FoodsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in(@user)
    @food1, @food2 = FactoryBot.create_list(:food, 2)
    @food_d = FactoryBot.create(:food, active: false)
    @foods = [@food1, @food2, @food_d]
    Rails.logger.debug("### @foods #{@foods.inspect}")
    lookup_table_test_load()
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Foods listing page' do
    foods_count = Food.all.count
    assert_equal(3, foods_count)

    # get default foods index listing (active foods only)
    get '/foods/'
    assert_response 200
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Foods Listing")
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three filter buttons, three for each active food, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 3 + 2 * 3 + 1, links_h[:count])

    # get foods index listing with deactivated foods only
    get '/foods?showing_active=deact'
    assert_response 200
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Foods Listing")
    links_h = get_links_hashes(page)
    # make sure we have links for the header, two filter buttons, three for each food, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 2 + 1 * 3 + 1, links_h[:count])

    # get foods index listing with all foods
    get '/foods?showing_active=all'
    assert_response 200
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "GetFoodIndexListing")
    assert_at_page(page, "Foods Listing")
    links_h = get_links_hashes(page)
    # make sure we have links for the header, two filter buttons, three for each food, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 2 + foods_count * 3 + 1, links_h[:count])

    # make sure that we have the correct links on the all foods page
    assert_page_headers(page, links_h, {})
    @foods.each do |fn|
      if fn.active == true
        assert_link_has(links_h, {
          link_text: "View",
          link_url: "/foods/#{fn.id}",
          page_title: "View Food: #{fn.name}",
          # debugging: true,
        })
        assert_link_has(links_h, {
          link_text: "Edit",
          link_url: "/foods/#{fn.id}/edit",
          page_title: "Edit Food: #{fn.name}",
          # debugging: true,
        })
        assert_link_has(links_h, {
          link_text: "Deactivate",
          link_url: "/foods/#{fn.id}",
          page_title: "View Food: #{fn.name}",
          # debugging: true,
          })
      else
        assert_link_has(links_h, {
          link_text: "Edit",
          link_url: "/foods/#{fn.id}/edit",
          link_has_classes: 'inactiveLink',
          # debugging: true,
          })
        # assert_link_has(links_h, {
        #   link_text: "Nutrients",
        #   link_url: "/nutrients_of_food/#{fn.id}",
        #   link_has_classes: 'inactiveLink',
        #   # debugging: true,
        # })
        assert_link_has(links_h, {
          link_text: "Reactivate",
          link_url: "/foods/#{fn.id}/reactivate",
          page_title: "Foods Listing",
          # debugging: true,
          })
      end
    end
    assert_link_has(links_h, {
      link_text: "New Food",
      link_url: "/foods/new",
      page_title: "New Food Page",
      page_subtitle: "New Food Page",
    })

  end

  test "should get new" do
    get "/foods/new"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "GetFoodIndexListing")
    assert_at_page(page, "New Food Page", "New Food Page")
    links_h = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(SITE_HEADER_LINK_COUNT, links_h[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h, {})

    # confirm all appropriate form fields exist
    assert_equal(1, page.css("form[action='/foods']").count)
    assert_equal(1, page.css('input#food_name').count)
    assert_equal(1, page.css('input#food_food_portion_amount').count)
    assert_equal(1, page.css('select#food_food_portion_unit').count)
    assert_equal(1, page.css('select#food_usda_food_cat_id').count)
    assert_equal(1, page.css("input[type='submit'][value='Create Food']").count)

  end

  test "should create new food as active" do
    @new_food = FactoryBot.build(:food)
    @new_food.name = "A new name for the food"
    @new_food.food_portion_amount = 2
    @new_food.food_portion_unit = "L"
    @new_food.usda_food_cat_id = 10
    @new_food.wweia_food_cat_id = 54
    # @new_food.usda_fdc_ids_json = [ 10000075 ]
    # @new_food.active = false
    assert_difference("Food.count") do
      post foods_url, params: {
        food: {
          # id: @new_food.id,
          name: @new_food.name,
          food_portion_amount: @new_food.food_portion_amount,
          food_portion_unit: @new_food.food_portion_unit,
          usda_food_cat_id: @new_food.usda_food_cat_id,
          wweia_food_cat_id: @new_food.wweia_food_cat_id,
          # usda_fdc_ids_json: @new_food.usda_fdc_ids_json,
          active: @new_food.active,
        }
      }
    end
    created_food = Food.last
    assert_equal(@new_food.name, created_food.name)
    assert_equal(@new_food.food_portion_amount, created_food.food_portion_amount)
    assert_equal(@new_food.food_portion_unit, created_food.food_portion_unit)
    assert_equal(@new_food.usda_food_cat_id, created_food.usda_food_cat_id)
    assert_equal(@new_food.wweia_food_cat_id, created_food.wweia_food_cat_id)
    # assert_equal(@new_food.usda_fdc_ids_json, created_food.usda_fdc_ids_json)
    # assert_equal(@new_food.active, created_food.active)
    assert_equal(true, created_food.active)
    assert_redirected_to food_url(created_food)
    follow_redirect!
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "CreatedNewFood")
    assert_at_page(page, "View Food: #{@new_food.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(SITE_HEADER_LINK_COUNT+['new','edit','delete'].count, links_h[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h, {
      current_food_record: created_food,
      # debugging_mode: true,
    })
  end

  test "should show active food" do
    skip "TODO - enable when food views are available in menus"
    get food_url(@food1)
    assert_response :success
  end

  test "should be able to view deactivated food" do
    skip "TODO - develop test for viewing deactivated foods when viewing foods is available"
  end

  test "should get active food edit" do
    get edit_food_url(@food1)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Edit Food: #{@food1.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header plus 3 links for navigation items at bottom of the page
    assert_equal(SITE_HEADER_LINK_COUNT + 3, links_h[:count])
    # make sure that we have the correct links on the page
    @food = @food1.clone # 'assert_page_headers' uses @food to determine if 'Food' Nutrients link should be dim or not.
    assert_page_headers(page, links_h, {
      current_food_record: @food1,
      debugging_mode: true,
    })

    assert_link_has(links_h, {
      link_text: "New Food",
      link_url: "/foods/new",
      page_title: "New Food Page",
      page_subtitle: "New Food Page",
    })
    assert_link_has(links_h, {
      link_text: "Deactivate this food",
      link_url: "/foods/#{@food1.id}",
      page_title: "View Food: #{@food1.name}",
    })

  end

  test "should update food" do
    # save off the original state of the food nutrient
    @changed_vals = @food1.dup
    Rails.logger.debug("%%% @food1: #{@food1.inspect}")

    # put in some changes
    # @changed_vals.id = -1  # this is the record to be updated
    @changed_vals.name = "A updated name for the food"
    @changed_vals.food_portion_amount = 2
    @changed_vals.food_portion_unit = "L"
    @changed_vals.usda_food_cat_id = 10
    @changed_vals.wweia_food_cat_id = 54
    # @changed_vals.usda_fdc_ids_json = [ 10000075 ]
    @changed_vals.active = false
    # @changed_vals.created_at = Date.tomorrow # should not be a permitted param
    # @changed_changed_foodnutrient.updated_at = Date.tomorrow # should not be a permitted param

    Rails.logger.debug("$$$ @food1: #{@food1.inspect}")
    Rails.logger.debug("$$$ @changed_vals: #{@changed_vals.inspect}")

    # confirm no new records are created from this update
    assert_no_changes("FoodNutrient.count", "No Foods should be created on update") do
      # update the food_nutrient in the controller update action
      patch food_url(@food1), params: {
        food: {
          # id: @food_nutrient.id, # note: this is passed in params
          name: @changed_vals.name,
          food_portion_amount: @changed_vals.food_portion_amount,
          food_portion_unit: @changed_vals.food_portion_unit,
          usda_food_cat_id: @changed_vals.usda_food_cat_id,
          wweia_food_cat_id: @changed_vals.wweia_food_cat_id,
          # usda_fdc_ids_json: @changed_vals.usda_fdc_ids_json,
          active: @changed_vals.active,
        }
      }
    end
    @food1.reload
    # page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "UpdatedFood")
    # assert_at_page(page, "View Food: #{@food1.name}")
    # links_h = get_links_hashes(page)
    # # make sure we have links for the header
    # assert_equal(SITE_HEADER_LINK_COUNT, links_h[:count])
    # # make sure that we have the correct links on the page
    # assert_page_headers(page, links_h)

    Rails.logger.debug("*** patch food is completed redirected? #{food_url(@food1).inspect}")
    assert_redirected_to food_url(@food1)
    follow_redirect!
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "CreatedNewFood")
    assert_at_page(page, "View Food: #{@food1.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(SITE_HEADER_LINK_COUNT+['new','edit','delete'].count, links_h[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h, {
      current_food_record: @food1,
      debugging_mode: true,
    })
    @updated_food = Food.find_by(id: @food1.id)
    Rails.logger.debug("$$$ @updated_food: #{@updated_food.inspect}")
    assert_equal(@changed_vals.name, @updated_food.name, "food lookup by id mismatch ??")
  end

  test "should not directly update usda_fdc_ids_json" do
    skip "ToDo - do not directly add directly to usda_fdc_ids_json"
  end

  test "should deactivate active food" do
    assert_equal(true, @food1.active)
    assert_no_changes("Food.count", "deactivation should not change number of food records") do
      delete food_url(@food1)
    end
    @food1.reload
    assert_equal(false, @food1.active)
    assert_redirected_to foods_url
  end

  test "should reactivate a deactived food" do
    assert_equal(false, @food_d.active)
    assert_no_changes("Food.count", "reactivation should not change number of food records") do
      get reactivate_food_url(@food_d)
    end
    @food_d.reload
    assert_equal(true, @food_d.active)
    assert_redirected_to foods_url
  end

end
