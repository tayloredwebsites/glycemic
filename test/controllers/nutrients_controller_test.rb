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
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three filter buttons,two for each active nutrient, and one at the bottom
    assert_equal(5 + 3 + 2 * 2 + 1, links_h[:count])

    # get nutrients index listing with only deactivated nutrients
    get '/nutrients?showing_active=deact'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three filter buttons,two for each active nutrient, and one at the bottom
    assert_equal(5 + 3 + 1 * 2 + 1, links_h[:count])

    # get nutrients index listing with all nutrients
    get '/nutrients?showing_active=all'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    links_h = get_links_hashes(page)
    # make sure we have links for the header, three filter buttons,two for each active nutrient, and one at the bottom
    assert_equal(5 + 3 + 3 * 2 + 1, links_h[:count])

    # make sure that we have the correct links on the all nutrients page
    assert_page_headers(page, links_h)

    @nutrients.each do |nut|
      if nut.active == true
        assert_link_has(links_h, {
          link_text: "Edit",
          link_url: "/nutrients/#{nut.id}/edit",
          page_title: "Edit Nutrient Page",
          page_subtitle: "for nutrient: #{nut.name}"
        })
        assert_link_has(links_h, {
          link_text: "Deactivate",
          link_url: "/nutrients/#{nut.id}",
          page_title: 'Nutrients Listing',
        })
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
    assert_equal(5, links_h[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, links_h)

    # confirm all appropriate form fields exist
    assert_equal(1, page.css("form[action='/nutrients']").count)
    assert_equal(1, page.css('input#nutrient_name').count)
    assert_equal(1, page.css('textarea#nutrient_desc').count)
    assert_equal(1, page.css('input#nutrient_usda_ndb_num').count)
    assert_equal(1, page.css("input[type='submit'][value='Create Nutrient']").count)
  end

  test "should create nutrient as active" do
    @new_nutrient = FactoryBot.build(:nutrient)
    assert_difference("Nutrient.count", 1, "a nutrient should be created") do
      post nutrients_url, params: {
        nutrient: {
          desc: @new_nutrient.desc,
          # id: @new_nutrient.id,
          name: @new_nutrient.name,
          usda_ndb_num: @new_nutrient.usda_ndb_num
        }
      }
    end
    new_nutrient = Nutrient.last
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
    assert_at_page(page, "Edit Nutrient Page", "Edit Nutrient Page", "for nutrient: #{@nutrient1.name}")
    links_h = get_links_hashes(page)
    # make sure we have links for the header plus 2 extra ones below
    assert_equal(5 + 2, links_h[:count])
    # make sure that we have the correct links on the page
    @nutrient = @nutrient1.clone # 'assert_page_headers' uses @nutrient to determine if 'Food' Nutrients link should be dim or not.
    assert_page_headers(page, links_h)

    assert_link_has(links_h, {
      link_text: "New Nutrient",
      link_url: "/nutrients/new",
      page_title: "New Nutrient Page",
      page_subtitle: "New Nutrient Page",
    })
    assert_link_has(links_h, {
      link_text: "Deactivate this nutrient",
      link_url: "/nutrients/#{@nutrient1.id}",
      page_title: 'Nutrients Listing',
    })
  end

  test "should update active nutrient" do
    # save off the original state of the nutrient (no need for exact copy)
    @changed_nutrient = @nutrient1.dup

    # put in some changes
    # @changed_nutrient.id = -1  # this is the record to be updated
    @changed_nutrient.name = "A new name for the nutrient"
    @changed_nutrient.desc = 'has been changed'
    @changed_nutrient.usda_ndb_num = 75
    # @changed_nutrient.created_at = Date.tomorrow # should not be a permitted param
    # @changed_changed_nutrient.updated_at = Date.tomorrow # should not be a permitted param

    Rails.logger.debug("$$$ @nutrient1: #{@nutrient1.inspect}")
    Rails.logger.debug("$$$ @changed_nutrient: #{@changed_nutrient.inspect}")

    # confirm no new records are created from this update
    assert_difference("Food.count", 0, "No Foods should be created") do
      # update the nutrient_nutrient in the controller update action
      patch nutrient_url(@nutrient1), params: {
        nutrient: {
          # id: @nutrient.id, # note: this is passed in params
          name: @changed_nutrient.name,
          desc: @changed_nutrient.desc,
          usda_ndb_num: @changed_nutrient.usda_ndb_num,
        }
      }
    end

    # confirm we are at the nutrient view page
    assert_redirected_to nutrient_url(@nutrient1)

    @updated_nutrient = Nutrient.find_by(id: @nutrient1.id)

    Rails.logger.debug("$$$ @updated_nutrient: #{@updated_nutrient.inspect}")

    assert_equal(@changed_nutrient.name, @updated_nutrient.name)
    assert_equal(@changed_nutrient.desc, @updated_nutrient.desc)
    assert_equal(@changed_nutrient.usda_ndb_num, @updated_nutrient.usda_ndb_num)
  end

  test "should deactivate active nutrient" do
    assert_equal(true, @nutrient1.active)
    assert_difference("Nutrient.count", 0, "Deactivate should not remove any records") do
      delete nutrient_url(@nutrient1)
    end
    @nutrient1.reload
    assert_equal(false, @nutrient1.active)
    assert_redirected_to nutrients_url
  end

  test "should reactivate a deactived nutrient" do
    assert_equal(false, @nutrient_d.active)
    assert_difference("Nutrient.count", 0) do
      get reactivate_nutrient_url(@nutrient_d)
    end
    @nutrient_d.reload
    assert_equal(true, @nutrient_d.active)
    assert_redirected_to nutrients_url
  end

end
