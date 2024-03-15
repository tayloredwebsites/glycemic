# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

SITE_HEADER_LINK_COUNT = 7
LISTINGS_FILTER_LINK_COUNT = 3 # Note: current (selected) page is a link that is in effect inactive

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
require 'capybara/minitest'

module ActiveSupport
	class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
	
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all
    # see https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#configure-your-test-suite
    
    include FactoryBot::Syntax::Methods

    # class ActionDispatch::IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL
    # Make `assert_*` methods behave like Minitest assertions
    include Capybara::Minitest::Assertions

    # Reset sessions and driver between tests
    teardown do
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end

    # helper for controllers, to confirm link goes to where we expect it
    def assert_gets_page(url, html_page_title, subtitle=nil, subtitle2=nil)
      get(url)
      assert_response :success
      page = Nokogiri::HTML.fragment(response.body)
      assert_at_page(page, html_page_title, subtitle, subtitle2)
    end

    # helper for controllers, to confirm link goes to where we expect it
    def assert_at_page(noko_page, expected_title, subtitle=nil, subtitle2=nil)
      returned_title = noko_page.css("title").text
      assert_equal expected_title, noko_page.css("title").text, "expected title: '#{expected_title}' got: '#{}'"
      if subtitle.present?
        h2 = noko_page.css('h2').first
        assert h2.text.include?(subtitle), 'subtitle mismatch'
        if subtitle2.present?
          assert h2.text.include?(subtitle2), 'subtitle2 mismatch'
        end
      end
    end

  end
end

# function to validate the page headers (for MVC pages in this app)
# Arguments:
# - noko_page - page from nokogiri
#   - e.g. page = Nokogiri::HTML.fragment(response.body)
# - links_hash - array of links on the page
#   - e.g. links_h = get_links_hashes(page)
# Parameters Hash:
#   - current_food_record - @food value used in controller for view
#   - debugging_mode - true or false to display extra debugging statements
# e.g.
#   assert_page_headers(page, links_h, {
#     current_food_record: created_food,
#     debugging_mode: true,
#   })
def assert_page_headers(noko_page, links_hash, params={})
  page_has_food_instance = (params[:page_has_food_record].present?) ? params[:page_has_food_record] === true : false
  current_food_record = (params[:current_food_record].present?) ? params[:current_food_record] : (@food.present?) ? @food : nil
  debugging_mode = (params[:debugging_mode].present? ? params[:debugging_mode] === true : false)
  Rails.logger.debug("*** assert_page_headers")
  Rails.logger.debug("*** assert_page_headers - @food: #{@food.inspect}")
  if current_food_record.present?
    Rails.logger.debug("*** assert_page_headers food present")
    assert_link_has(links_hash, {
      link_text: "#{current_food_record.name} Nutrients",
      link_path: "/nutrients_of_food/#{current_food_record.id}",
      page_title: "Nutrients of Food Listing",
      page_subtitle: "for food:",
      page_subtitle2: current_food_record.name,
    })
  else
    Rails.logger.debug("*** assert_page_headers - food not present") if debugging_mode
    pageInactiveLinkCount = noko_page.css("#food_nutrients_link[class='inactiveLink']").count
    Rails.logger.debug("*** assert_page_headers - pageInactiveLinkCount: #{pageInactiveLinkCount}") if debugging_mode
    assertInactiveLinkCount = (params[:page_has_food_instance].present?) ? 0 : (@page.present?) ? 0 : 1
    assert_equal(assertInactiveLinkCount, pageInactiveLinkCount, "inactive link count is #{pageInactiveLinkCount}, not '#{assertInactiveLinkCount}'")
  end
  assert_link_has(links_hash, {
    link_text: "Foods Listing",
    link_path: "/foods",
    page_title: "Foods Listing",
    :debugging => debugging_mode,
  })
  assert_link_has(links_hash, {
    link_text: "Nutrients Listing",
    link_path: "/nutrients",
    page_title: "Nutrients Listing",
    :debugging => debugging_mode,
  })
  assert_link_has(links_hash, {
    link_text: "Home",
    link_path: "/",
    page_title: "Food Nutrients Home",
    :debugging => debugging_mode,
  })
  assert_link_has(links_hash, {
    link_text: "Sign Out",
    link_path: "/signout",
    :debugging => debugging_mode,
  })

end
