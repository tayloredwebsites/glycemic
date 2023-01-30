require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
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

  test "logged in user should get index and see links" do
    get home_index_url
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    h1 = page.css('h1').first
    Rails.logger.debug("$$$ h1: #{h1.inspect}")
    assert h1.text.include?('Home Page')
    # make a hash of all links on the page
    page_links = page.css('a')
    assert_equal(3, page_links.count)
    link_map = page_links.map{|a| [a.text, a['href']]}.to_h
    Rails.logger.debug("link_map: #{link_map.inspect}")
    assert_match("/foods",link_map['Foods Listing']) # has Foods Listing link
    assert_match("/nutrients",link_map['Nutrients Listing']) # has Nutrients Listing link
    assert_match("/signout",link_map['Sign Out']) # has Sign Out link
  end

end
