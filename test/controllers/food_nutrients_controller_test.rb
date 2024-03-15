# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

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
    @nutrient_d = FactoryBot.create(:nutrient, active: false)
    @food_nutrient = FactoryBot.create(:food_nutrient, food: @food, nutrient: @nutrient)
    @food_nutrient2 = FactoryBot.create(:food_nutrient, food: @food, nutrient: @nutrient2)
    @food_nutrient_d = FactoryBot.create(:food_nutrient, active: false, food: @food, nutrient: @nutrient_d)
    @food_nutrients = [@food_nutrient, @food_nutrient2, @food_nutrient_d]
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Nutrients of a Food listing page' do
    foods_count = Food.all.count
    assert_equal(1, foods_count)
    nutrients_count = Nutrient.all.count
    assert_equal(4, nutrients_count)

    # get default nutrients of foods index listing (active nutrients only)
    get "/nutrients_of_food/#{@food.id}"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "GetNutrientsOfFood")
    assert_at_page(page, "Nutrients of Food Listing", 'Nutrients of Food Listing', "for food: #{@food.name}")
    links_h = get_links_hashes(page)
    # Rails.logger.debug("$$$ assert_link_has links_h: #{JSON.pretty_generate(links_h)}")
    # make sure we have links for the header, three for the filter, two for each of the two active nutrient, and one at the bottom
    food_nutrients_count = FoodNutrient.where(food_id: @food.id, active: true).count
    assert_equal(2, food_nutrients_count)
    assert_equal(SITE_HEADER_LINK_COUNT + 3 + (food_nutrients_count * 2) + 1, links_h[:count])

    # get nutrients of foods index listing (deactivated nutrients only)
    get "/nutrients_of_food/#{@food.id}?showing_active=deact"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Nutrients of Food Listing", 'Nutrients of Food Listing', "for food: #{@food.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three for the filter, two for the one deactivated nutrient, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 3 + 1 * 2 + 1, links_h[:count])

    # get default nutrients of foods index listing (active nutrients only)
    get "/nutrients_of_food/#{@food.id}?showing_active=all"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Nutrients of Food Listing", 'Nutrients of Food Listing', "for food: #{@food.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three for the filter, three for each of the nutrients, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 3 + 3 * 2 + 1, links_h[:count])

    # make sure that we have the correct links on the all nutrients listing page
    # save_noko_page(page, "ActiveNutrientsOfFood")
    assert_page_headers(page, links_h, {:assert_page_headers => false})
    # assert_gets_page("/signout", 'Log in')
    @food_nutrients.each do |fn|
      if fn.active == true
        assert_link_has(links_h, {
          link_text: "Edit",
          link_path: "/food_nutrients/#{fn.id}/edit",
          page_title: "Food Nutrient Edit Page",
          page_subtitle: "Food Nutrient Edit Page",
          page_subtitle2: "for food: #{@food.name}",
        })
        assert_link_has(links_h, {
          link_text: "Deactivate",
          link_path: "/food_nutrients/#{fn.id}",
          page_title: "Nutrients of Food Listing",
          page_subtitle: "for food: #{@food.name}",
        })
      else
        assert_link_has(links_h, {
          link_text: "Edit",
          link_path: "/food_nutrients/#{fn.id}/edit",
          link_has_classes: 'inactiveLink',
        })
        assert_link_has(links_h, {
          link_text: "Reactivate",
          link_path: "/food_nutrients/#{fn.id}/reactivate",
          page_title: "Nutrients of Food Listing",
          page_subtitle: "for food: #{@food.name}",
        })
      end
    end
    assert_link_has(links_h, {
      link_text: "New food nutrient",
      link_path: "/food_nutrients/new?food_id=#{@food.id}",
      page_title: "New Food Nutrient",
      page_subtitle: "New Food Nutrient",
      page_subtitle2: "for food: #{@food.name}",
    })

  end

  test "should get new" do
    get "/food_nutrients/new?food_id=#{@food.id}"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "GetNewFood")
    assert_at_page(page, "New Food Nutrient", "New Food Nutrient", "for food: #{@food.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(SITE_HEADER_LINK_COUNT, links_h[:count])
    Rails.logger.debug("check the header links")
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h)

    # confirm that the only option displayed is the third nutrient, which has not been assigned to this food yet.
    assert_select_has(page, 'food_nutrient_nutrient_id', {
      options_count: 1,
      selected_count: 0,
      displayed_option: @nutrient3.name,
      # debugging: true,
    })
    assert_equal(1, page.css("input[type='submit'][value='Create Food nutrient']").count)
    assert_equal(1, page.css("form[action='/food_nutrients']").count)
    # confirm hidden input field for food_id exists and is the correct value
    food_id_node = page.css("input#food_nutrient_food_id")
    Rails.logger.debug("$$$ food_id_node: #{food_id_node}")
    assert_equal(1, food_id_node.count)
    Rails.logger.debug("$$$ food_id_node['value']: #{food_id_node.first['value']}")
    assert_equal(@food.id.to_s, food_id_node.first['value'])
  end

  test "should create food_nutrient as active" do
    @new_food_nutrient = FactoryBot.build(:food_nutrient, food: @food, nutrient: @nutrient)
    Rails.logger.debug("*** @new_food_nutrient: #{@new_food_nutrient.inspect}")
    Rails.logger.debug("*** food id: #{@food.id}")
    Rails.logger.debug("*** nutrient id: #{@nutrient.id}")
    Rails.logger.debug("*** FoodNutrient.count: #{FoodNutrient.count}")
    # assert_difference("FoodNutrient.count") do
      post food_nutrients_path, params: {
        food_nutrient: {
          # food_id: @food.id,
          food_id: @new_food_nutrient.food_id,
          # nutrient_id: @nutrient.id,
          nutrient_id: @new_food_nutrient.nutrient_id,
          amount: @new_food_nutrient.amount,
          # samples_json: @new_food_nutrient.samples_json,
        }
      }
    # end
    Rails.logger.debug("*** FoodNutrient.count: #{FoodNutrient.count}")
    new_food_nutrient = FoodNutrient.last
    assert_equal(true, new_food_nutrient.active)
    assert_redirected_to nutrients_of_food_path(@food.id)
  end

  test "should view active food_nutrient" do
    skip "TODO - enable when food nutrient views are available in menus"
    get food_nutrient_path(@food_nutrient)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "'#{@food.name}' Nutrient View Page", 'for food nutrient', @food_nutrient.nutrient.name)
    links_h = get_links_hashes(page)
    # make sure we links for the header, two for each food_nutrient action (edit, delete), and the 'new' action at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 3, links_h[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h)
    assert_link_has(links_h, {
      link_text: "New nutrient for #{@food.name}",
      link_path: "/food_nutrients/new?food_id=#{@food.id}",
      page_title: "New Food Nutrient",
      page_subtitle: "for food:",
      page_subtitle2: @food.name,
    })
    assert_link_has(links_h, {
      link_text: "Edit this nutrient for #{@food.name}",
      link_path: "/food_nutrients/#{@food_nutrient.id}/edit",
      page_title: "Food Nutrient Edit Page",
      page_subtitle: "for food: #{@food.name}",
      page_subtitle2: "and nutrient: #{@food_nutrient.nutrient.name}",
      # debugging: true,
    })
    assert_link_has(links_h, {
      link_text: "Remove this nutrient from #{@food.name}",
      link_path: "/food_nutrients/#{@food_nutrient.id}",
      # TODO: validate the "Are you sure?" alert
      # TODO: validate the delete page is linked to properly
    })

    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")
  end

  test "should be able to view deactivated food_nutrient" do
    skip "TODO - develop test for viewing deactivated food nutrients when viewing food nutrients is available"
  end

  test "should start edit on active food" do
    get edit_food_nutrient_path(@food_nutrient) # "/food_nutrient/#{@food_nutrient.id}/edit"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    # save_noko_page(page, "EditActiveFood")
    links_h = get_links_hashes(page)
    # Rails.logger.debug("$$$ assert_link_has links_h: #{JSON.pretty_generate(links_h)}")
    Rails.logger.debug("*** @food: #{@food.inspect}")
    assert_at_page(page, "Food Nutrient Edit Page", "for food: #{@food.name}", "and nutrient: #{@food_nutrient.nutrient.name}")
    # make sure we have links for the header, plus 3 at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + 3, links_h[:count], "Header link count is #{links_h[:count]}, not the expected: '#{SITE_HEADER_LINK_COUNT + 3}'")
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h, {
      # debugging: true,
    })

    # confirm that the only option displayed is the third nutrient, which has not been assigned to this food yet.
    # No select on nutrient, so, check:
    # the hidden field with the food_nutrient id exists and is correct:
    food_id = get_input_hidden_field_value(page, {
      hidden_field_id: "food_nutrient_food_id",
      # debugging: true,
    })
    Rails.logger.debug("*** hidden food nutrient id: #{food_id}")
    assert_equal(@food_nutrient.food_id.to_s, food_id, "hidden_food_nutrient_id: #{food_id} is not the expected: #{@food_nutrient.food_id.to_s}")
    # the hidden field with the food_nutrient id exists and is correct:
    hidden_nutrient_id = get_input_hidden_field_value(page, { hidden_field_id: "food_nutrient_nutrient_id" })
    assert_equal(@food_nutrient.nutrient_id.to_s, hidden_nutrient_id, "hidden_food_nutrient_id: #{hidden_nutrient_id} is not the expected: #{@food_nutrient.nutrient_id.to_s}")
    # the nutrient name is displayed:
    food_name = page.css("#food_nutrient_nutrient_name").text
    assert_equal(@food_nutrient.nutrient.name, food_name, "Food name: #{food_name} is not the expected: #{@food_nutrient.nutrient.name}")
    # confirm all appropriate fields exist
    # assert_equal(1, page.css('input#food_nutrient_portion').count, "food_nutrient_portion field does not exist")
    # # assert_select_has(page, 'portion_unit', {
    # #   displayed_option: @food_nutrient.portion_unit,
    # # })
    assert_equal(1, page.css('input#food_nutrient_amount').count, "food_nutrient_amount field does not exist")
    # assert_select_has(page, 'amount_unit', {
    #   displayed_option: @food_nutrient.amount_unit,
    # })
    # assert_equal(1, page.css('textarea#food_nutrient_desc').count)
    assert_equal(1, page.css("input[type='submit'][value='Update Food nutrient']").count, "update button does not exist")
    assert_equal(1, page.css("form[action='/food_nutrients/#{@food_nutrient.id}']").count, "food_nutrients form does not exist")
    # confirm hidden input field for food_id exists and is the correct value
    food_id_node = page.css("input#food_nutrient_food_id")
    Rails.logger.debug("$$$ food_id_node: #{food_id_node}")
    assert_equal(1, food_id_node.count)
    Rails.logger.debug("$$$ food_id_node['value']: #{food_id_node.first['value']}")
    assert_equal(@food.id.to_s, food_id_node.first['value'])

    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")
    page = Nokogiri::HTML.fragment(response.body)

  end

  test "should update active food_nutrient" do
    # save off the original state of the food nutrient
    @changed_nutrient = @food_nutrient.dup

    # put in some changes
    # @changed_nutrient.id = -1  # this is the record to be updated
    @changed_nutrient.nutrient_id = 99999 # should not let foreign key be changed
    @changed_nutrient.food_id = 99999  # should not let foreign key be changed
    @changed_nutrient.amount = 75

    Rails.logger.debug("$$$ @food_nutrient: #{@food_nutrient.inspect}")
    Rails.logger.debug("$$$ @changed_nutrient: #{@changed_nutrient.inspect}")

    # confirm no new records are created from this update
    assert_no_changes("FoodNutrient.count", "No Food Nutrients should be created on update") do
      # update the food_nutrient in the controller update action
      patch food_nutrient_path(@food_nutrient), params: {
        food_nutrient: {
          # id: @food_nutrient.id, # note: this is passed in params
          nutrient_id: @changed_nutrient.nutrient_id,  # should not let foreign key be changed
          food_id: @changed_nutrient.food_id,  # should not let foreign key be changed
          amount: @changed_nutrient.amount,
        }
      }
    end

    # confirm we are at the food nutrient view page
    assert_redirected_to nutrients_of_food_path(@food_nutrient.food_id)

    @updated_food_nutrient = FoodNutrient.find_by(id: @food_nutrient.id)

    Rails.logger.debug("$$$ @updated_food_nutrient: #{@updated_food_nutrient.inspect}")

    # assert_equal(@orig_nutrient.id, @updated_food_nutrient.id) # should not have changed - Note: (dup) does not have ID set
    assert_equal(@food_nutrient.nutrient_id, @updated_food_nutrient.nutrient_id) # should not let foreign key be changed
    assert_equal(@food_nutrient.food_id, @updated_food_nutrient.food_id) # should not let foreign key be changed
    assert_equal(@changed_nutrient.amount, @updated_food_nutrient.amount)
    assert_equal(@food_nutrient.created_at, @updated_food_nutrient.created_at) # should not have changed - note: (dup) is not set
    assert_not_equal(@food_nutrient.updated_at, @updated_food_nutrient.updated_at) # should have changed - note: (dup) is not set

  end

  test "should deactivate food_nutrient" do
    assert_equal(true, @food_nutrient.active)
    assert_no_changes("FoodNutrient.count", 'deactivation should not change number of food nutrient records') do
      delete food_nutrient_path(@food_nutrient)
    end
    @food_nutrient.reload
    assert_equal(false, @food_nutrient.active)
    assert_redirected_to "/nutrients_of_food/#{@food_nutrient.food_id}"
  end

  test "should reactivate a deactived food_nutrient" do
    assert_equal(false, @food_nutrient_d.active)
    assert_no_changes("FoodNutrient.count", "reactivation should not change number of food nutrient records") do
      get reactivate_food_nutrient_path(@food_nutrient_d)
    end
    @food_nutrient_d.reload
    assert_equal(true, @food_nutrient_d.active)
    assert_redirected_to "/nutrients_of_food/#{@food_nutrient_d.food_id}"
  end

end
