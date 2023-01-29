require "test_helper"

class HomeControllerTests
  class SignedInHomeTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include Capybara::DSL

    setup do
      @user = FactoryBot.create(:user)
      sign_in(@user)
    end

    # called after every single test
    teardown do
      # # when controller is using cache it may be a good idea to reset it afterwards
      # Rails.cache.clear
    end

    test "logged in user should get index" do
      get home_index_url
      assert_response :success

      # html = Nokogiri::HTML.fragment(response.body)
      # h1 = html.css('h1').first
      # Rails.logger.info("$$$ h1: #{h1.inspect}")
      # assert h1.text.include?('Home#index')
      # h2 = html.css('h2')
      # assert_equal(0, h2.count)
    end

  end

  class UnconfirmedHomeTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      assert_emails 1 do
        @unconfirmed_user = FactoryBot.create(:unconfirmed_user)
      end
    end

    # called after every single test
    teardown do
      # # when controller is using cache it may be a good idea to reset it afterwards
      # Rails.cache.clear
    end

    test "user should not get index if not confirmed" do
      sign_in(@unconfirmed_user)
      get home_index_url
      assert_response 302
      # # see nokogiri docs at https://nokogiri.org/rdoc/ (use search)
      # page = Nokogiri::HTML.fragment(response.body)
      # redir_url = page.css('a').first
      # assert_match(/sign_in/,redir_url['href'])
      assert_redirected_to new_user_session_path
    end

  end

  class NoUserHomeTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
    end

    # called after every single test
    teardown do
      # # when controller is using cache it may be a good idea to reset it afterwards
      # Rails.cache.clear
    end

    test "user not signed in should get login page" do
      get home_index_url
      assert_response 302
      # # see nokogiri docs at https://nokogiri.org/rdoc/ (use search)
      # page = Nokogiri::HTML.fragment(response.body)
      # redir_url = page.css('a').first
      # assert_match(/sign_in/,redir_url['href'])
      assert_redirected_to new_user_session_path
    end

  end

end
