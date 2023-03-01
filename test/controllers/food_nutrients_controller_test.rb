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
    assert_page_headers(page, linksH)
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
        # TODO: validate the "Are you sure?" alert
        # TODO: validate the delete page is linked to properly
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
    assert_page_headers(page, linksH)

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
    assert_page_headers(page, linksH)
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
      # TODO: validate the "Are you sure?" alert
      # TODO: validate the delete page is linked to properly
    })
  
    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")

  end

  test "should get edit" do
    get edit_food_nutrient_url(@food_nutrient) # "/food_nutrient/#{@food_nutrient.id}/edit"
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Food Nutrient Edit Page", "for food: #{@food.name}", "and nutrient: #{@food_nutrient.nutrient.name}")
    linksH = get_links_hashes(page)
    # make sure we have links for the header, plus 3 at the bottom
    assert_equal(5+3, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, linksH)

    # confirm that the only option displayed is the third nutrient, which has not been assigned to this food yet.
    # No select on nutrient, so, check:
    # the hidden field with the food_nutrient id exists and is correct:
    assert_equal(@food_nutrient.food_id.to_s, get_input_hidden_field_value(page, {
      :hidden_field_id => "food_nutrient_food_id"
    }))
    # the hidden field with the food_nutrient id exists and is correct:
    assert_equal(@food_nutrient.nutrient_id.to_s, get_input_hidden_field_value(page, {
      :hidden_field_id => "food_nutrient_nutrient_id"
    }))
    # the nutrient name is displayed:
    assert_equal(@food_nutrient.nutrient.name, page.css("#food_nutrient_nutrient_name").text)
    # confirm all appropriate fields exist
    assert_equal(1, page.css('input#food_nutrient_portion').count)
    assert_select_has(page, 'portion_unit', {
      :displayed_option => @food_nutrient.portion_unit,
    })
    assert_equal(1, page.css('input#food_nutrient_amount').count)
    assert_select_has(page, 'amount_unit', {
      :displayed_option => @food_nutrient.amount_unit,
    })
    assert_equal(1, page.css('textarea#food_nutrient_desc').count)
    assert_equal(1, page.css("input[type='submit'][value='Update Food nutrient']").count)
    assert_equal(1, page.css("form[action='/food_nutrients/#{@food_nutrient.id}']").count)
    # confirm hidden input field for food_id exists and is the correct value
    food_id_node = page.css("input#food_nutrient_food_id")
    Rails.logger.debug("$$$ food_id_node: #{food_id_node}")
    assert_equal(1, food_id_node.count)
    Rails.logger.debug("$$$ food_id_node['value']: #{food_id_node.first['value']}")
    assert_equal(@food.id.to_s, food_id_node.first['value'])

    assert_gets_page("/food_nutrients/new?food_id=#{@food.id}", 'New Food Nutrient', "for food: #{@food.name}")
    page = Nokogiri::HTML.fragment(response.body)

  end

  test "should update food_nutrient" do
    # save off the original state of the food nutrient
    @changed_nutrient = @food_nutrient.dup

    # put in some changes
    # @changed_nutrient.id = -1  # this is the record to be updated
    @changed_nutrient.nutrient_id = 99999 # should not let foreign key be changed
    @changed_nutrient.food_id = 99999  # should not let foreign key be changed
    # @changed_nutrient.study = true # not implemented yet
    # @changed_nutrient.study_weight = 1.0 # not implemented yet
    # @changed_nutrient.avg_rec_id = -1 # not implemented yet
    @changed_nutrient.portion = 200
    @changed_nutrient.portion_unit = 'l'
    @changed_nutrient.amount = 75
    @changed_nutrient.amount_unit = 'ug'
    @changed_nutrient.desc = 'Has been changed.'
    # @changed_nutrient.created_at = Date.tomorrow # should not be a permitted param
    # @changed_nutrient.updated_at = Date.tomorrow # should not be a permitted param

    Rails.logger.debug("$$$ @food_nutrient: #{@food_nutrient.inspect}")
    Rails.logger.debug("$$$ @changed_nutrient: #{@changed_nutrient.inspect}")

    # confirm no new records are created from this update
    assert_difference("FoodNutrient.count", 0, "No Food Nutrients should be created") do
      # update the food_nutrient in the controller update action
      patch food_nutrient_url(@food_nutrient), params: {
        food_nutrient: {
          # id: @food_nutrient.id, # note: this is passed in params
          nutrient_id: @changed_nutrient.nutrient_id,  # should not let foreign key be changed
          food_id: @changed_nutrient.food_id,  # should not let foreign key be changed
          # study: @changed_nutrient.study, # not implemented yet
          # study_weight: @changed_nutrient.study_weight, # not implemented yet
          # avg_rec_id: @changed_nutrient.avg_rec_id, # not implemented yet
          portion: @changed_nutrient.portion,
          portion_unit: @changed_nutrient.portion_unit,
          amount: @changed_nutrient.amount,
          amount_unit: @changed_nutrient.amount_unit,
          desc: @changed_nutrient.desc,
        }
      }
    end

    # confirm we are at the food nutrient view page
    assert_redirected_to food_nutrient_url(@food_nutrient)

    @updated_food_nutrient = FoodNutrient.find_by(id: @food_nutrient.id)

    Rails.logger.debug("$$$ @updated_food_nutrient: #{@updated_food_nutrient.inspect}")

    # assert_equal(@orig_nutrient.id, @updated_food_nutrient.id) # should not have changed - Note: (dup) does not have ID set
    assert_equal(@food_nutrient.nutrient_id, @updated_food_nutrient.nutrient_id) # should not let foreign key be changed
    assert_equal(@food_nutrient.food_id, @updated_food_nutrient.food_id) # should not let foreign key be changed
    # assert_equal(@food_nutrient.study, @updated_food_nutrient.study) # not implemented yet
    # assert_equal(@food_nutrient.study_weight, @updated_food_nutrient.study_weight) # not implemented yet
    # assert_equal(@food_nutrient.avg_rec_id, @updated_food_nutrient.avg_rec_id) # not implemented yet
    assert_equal(@changed_nutrient.portion, @updated_food_nutrient.portion)
    assert_equal(@changed_nutrient.portion_unit, @updated_food_nutrient.portion_unit)
    assert_equal(@changed_nutrient.amount, @updated_food_nutrient.amount)
    assert_equal(@changed_nutrient.amount_unit, @updated_food_nutrient.amount_unit)
    assert_equal(@changed_nutrient.desc, @updated_food_nutrient.desc)
    assert_equal(@food_nutrient.created_at, @updated_food_nutrient.created_at) # should not have changed - note: (dup) is not set
    assert_not_equal(@food_nutrient.updated_at, @updated_food_nutrient.updated_at) # should have changed - note: (dup) is not set

  end

  test "should destroy food_nutrient" do
    assert_difference("FoodNutrient.count", -1) do
      delete food_nutrient_url(@food_nutrient)
    end

    assert_redirected_to food_nutrients_url
  end
end
