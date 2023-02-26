ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
require 'capybara/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all
  # see https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#configure-your-test-suite
  include FactoryBot::Syntax::Methods

    #   # Add more helper methods to be used by all tests here...
    # end

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
  def assert_gets_page(url, html_page_title, subtitle=nil, subtitle2)
    get(url)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, html_page_title, subtitle=nil, subtitle2=nil)
  end
  
  # helper for controllers, to confirm link goes to where we expect it
  def assert_at_page(noko_page, html_page_title, subtitle=nil, subtitle2=nil)
    assert_equal html_page_title, noko_page.css("title").text, 'title mismatch'
    if subtitle.present?
      h2 = noko_page.css('h2').first
      assert h2.text.include?(subtitle), 'subtitle mismatch'
      if subtitle2.present?
        assert h2.text.include?(subtitle2), 'subtitle2 mismatch'
      end
    end
  end
  
end
