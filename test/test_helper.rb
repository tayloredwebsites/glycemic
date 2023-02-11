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
  def assert_gets_page(url, html_page_title, subtitle=nil)
    get(url)
    assert_response :success
    assert_select "title", html_page_title
    if subtitle.present?
      page = Nokogiri::HTML.fragment(response.body)
      h2 = page.css('h2').first
      assert h2.text.include?(subtitle)
    end
  end
  
end
