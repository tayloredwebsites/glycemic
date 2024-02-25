# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require "test_helper"
require "helpers/user_helper"
require "helpers/nokogiri_helper"

class NutrientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user
    @nutrient1, @nutrient2 = FactoryBot.create_list(:nutrient, 2)
    @nutrient_d = FactoryBot.create(:nutrient, active: false)
    @nutrients = [@nutrient1, @nutrient2, @nutrient_d]
    Rails.logger.debug("### @nutrients #{@nutrients.inspect}")
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Nutrients listing page' do
    nutrients_count = Nutrient.all.count
    assert_equal(3, nutrients_count)

    # get default nutrients index listing with only active nutrients
    get '/nutrients/'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    save_noko_page(page, "NutrientListing")
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    links_h = get_links_hashes(page)
    # Rails.logger.debug("$$$ assert_link_has links_h: #{JSON.pretty_generate(links_h)}")
    # make sure we have links for the header, three filter buttons, three for 2 active nutrients, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + LISTINGS_FILTER_LINK_COUNT + 3 * 2 + 1, links_h[:count])

    # get nutrients index listing with only deactivated nutrients
    get '/nutrients?showing_active=deact'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three filter buttons,three for 1 deactivated nutrient, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + LISTINGS_FILTER_LINK_COUNT + 3 * 1 + 1, links_h[:count])

    # get nutrients index listing with all nutrients
    get '/nutrients?showing_active=all'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three filter buttons, three for all 3 active and deactivated nutrients, and one at the bottom
    assert_equal(SITE_HEADER_LINK_COUNT + LISTINGS_FILTER_LINK_COUNT + 3 * 3 + 1, links_h[:count])

    # make sure that we have the correct links on the all nutrients page
    assert_page_headers(page, links_h)

    @nutrients.each do |nut|
      if nut.active == true
        assert_link_has(links_h, {
          link_text: "Edit",
          link_url: "/nutrients/#{nut.id}/edit",
          page_title: "Edit Nutrient: #{nut.name}"
        })
        # TODO: develop method to safely test deactivation link eventual location
        #  consider doing an active flag reset after confirming that it is deactivated
        #  Note: see if get the method in the get_links_hashes method, and then pass it on
        # assert_link_has(links_h, {
        #   link_text: "Deactivate",
        #   link_url: "/nutrients/#{nut.id}",
        #   page_title: 'Nutrients Listing',
        #   debugging: true,
        # })
      else
        assert_link_has(links_h, {
          link_text: "Edit",
          link_url: "/nutrients/#{nut.id}/edit",
          link_has_classes: 'inactiveLink',
        })
        assert_link_has(links_h, {
          link_text: "Reactivate",
          link_url: "/nutrients/#{nut.id}/reactivate",
          page_title: 'Nutrients Listing',
        })
      end
    end
    assert_link_has(links_h, {
      link_text: "New Nutrient",
      link_url: "/nutrients/new",
      page_title: "New Nutrient Page",
      page_subtitle: "New Nutrient Page",
    })

  end

  test "should get new" do
    get new_nutrient_url
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "New Nutrient Page", "New Nutrient Page")
    links_h = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(SITE_HEADER_LINK_COUNT, links_h[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h)

    # confirm all appropriate form fields exist
    assert_equal(1, page.css("form[action='/nutrients']").count)
    assert_equal(1, page.css('input#nutrient_name').count)
    assert_equal(1, page.css('input#nutrient_usda_nutrient_id').count)
    assert_equal(1, page.css('input#nutrient_usda_nutrient_num').count)
    assert_equal(1, page.css('select#nutrient_unit_code').count)
    assert_equal(1, page.css("input[type='submit'][value='Create Nutrient']").count)
  end

  test "should create nutrient as active" do
    @new_nutrient = FactoryBot.build(:nutrient)
    Rails.logger.debug("*** @new_nutrient: #{@new_nutrient.inspect}")
    assert_difference("Nutrient.count") do
      post nutrients_url, params: {
        nutrient: {
          # id: @new_nutrient.id,
          name: @new_nutrient.name,
          usda_nutrient_id: @new_nutrient.usda_nutrient_id,
          usda_nutrient_num: @new_nutrient.usda_nutrient_num,
          unit_code: @new_nutrient.unit_code,
        }
      }
    end
    new_nutrient = Nutrient.last
    assert_equal(@new_nutrient.name, new_nutrient.name)
    assert_equal(@new_nutrient.usda_nutrient_id, new_nutrient.usda_nutrient_id)
    assert_equal(@new_nutrient.usda_nutrient_num, new_nutrient.usda_nutrient_num)
    assert_equal(@new_nutrient.unit_code, new_nutrient.unit_code)
    assert_equal(true, new_nutrient.active)
    assert_redirected_to nutrient_url(new_nutrient)
  end

  test "should show nutrient" do
    skip "TODO - enable when nutrient views are available in menus"
    get nutrient_url(@nutrient1)
    assert_response :success
  end

  test "should view deactivated nutrient" do
    skip "TODO - develop test for viewing deactivated nutrients when viewing nutrients is available"
  end

  test "should get active nutrient edit" do
    get edit_nutrient_url(@nutrient1)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Edit Nutrient: #{@nutrient1.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header plus 2 extra ones below
    assert_equal(SITE_HEADER_LINK_COUNT + 3, links_h[:count])
    # make sure that we have the correct links on the page
    @nutrient = @nutrient1.clone # 'assert_page_headers' uses @nutrient to determine if 'Food' Nutrients link should be dim or not.
    assert_page_headers(page, links_h)

    assert_link_has(links_h, {
      link_text: "New Nutrient",
      link_url: "/nutrients/new",
      page_title: "New Nutrient Page",
      page_subtitle: "New Nutrient Page",
    })
    # TODO: develop method to safely test deactivation link eventual location
    #  consider doing an active flag reset after confirming that it is deactivated
    #  Note: see if get the method in the get_links_hashes method, and then pass it on
    # assert_link_has(links_h, {
    #   link_text: "Deactivate this nutrient",
    #   link_url: "/nutrients/#{@nutrient1.id}",
    #   page_title: 'Nutrients Listing',
    # })
  end

  test "should update active nutrient" do
    # save off the original state of trighthe nutrient (no need for exact copy)
    @changed_nutrient = @nutrient1.dup

    # put in some changes
    # @changed_nutrient.id = -1  # this is the record to be updated
    @changed_nutrient.name = "A new name for the nutrient"
    # @changed_nutrient.created_at = Date.tomorrow # should not be a permitted param
    # @changed_changed_nutrient.updated_at = Date.tomorrow # should not be a permitted param

    Rails.logger.debug("$$$ @nutrient1: #{@nutrient1.inspect}")
    Rails.logger.debug("$$$ @changed_nutrient: #{@changed_nutrient.inspect}")

    # confirm no new records are created from this update
    assert_no_changes("Nutrient.count", "reactivation should not change number of nutrient records") do
      # update the nutrient_nutrient in the controller update action
      patch nutrient_url(@nutrient1), params: {
        nutrient: {
          # id: @nutrient.id, # note: this is passed in params
          name: @changed_nutrient.name,
          usda_nutrient_id: @changed_nutrient.usda_nutrient_id,
          usda_nutrient_num: @changed_nutrient.usda_nutrient_num,
          unit_code: @changed_nutrient.unit_code,
        }
      }
    end

    # confirm we are at the nutrient view page
    assert_redirected_to nutrient_url(@nutrient1)

    @updated_nutrient = Nutrient.find_by(id: @nutrient1.id)

    Rails.logger.debug("$$$ @updated_nutrient: #{@updated_nutrient.inspect}")

    assert_equal(@changed_nutrient.name, @updated_nutrient.name)
    assert_equal(@changed_nutrient.usda_nutrient_id, @updated_nutrient.usda_nutrient_id)
    assert_equal(@changed_nutrient.usda_nutrient_num, @updated_nutrient.usda_nutrient_num)
    assert_equal(@changed_nutrient.unit_code, @updated_nutrient.unit_code)
  end

  test "should deactivate active nutrient" do
    assert_equal(true, @nutrient1.active)
    assert_no_changes("Nutrient.count", "reactivation should not change number of nutrient records") do
      delete nutrient_url(@nutrient1)
    end
    @nutrient1.reload
    assert_equal(false, @nutrient1.active)
    assert_redirected_to nutrients_url
  end

  test "should reactivate a deactived nutrient" do
    assert_equal(false, @nutrient_d.active)
    assert_no_changes("Nutrient.count", "reactivation should not change number of nutrient records") do
      get reactivate_nutrient_url(@nutrient_d)
    end
    @nutrient_d.reload
    assert_equal(true, @nutrient_d.active)
    assert_redirected_to nutrients_url
  end

end
