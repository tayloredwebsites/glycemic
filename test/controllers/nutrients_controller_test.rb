require "test_helper"
require "helpers/user_helper"

class NutrientsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Capybara::DSL

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user
    @nutrient, @nutrient2 = FactoryBot.create_list(:nutrient, 2)
  end

  # called after every single test
  teardown do
    # # when controller is using cache it may be a good idea to reset it afterwards
    # Rails.cache.clear
  end

  test 'be able to get the Nutrients listing page' do
    get '/nutrients/'
    assert_response 200
    page = Nokogiri::HTML.fragment(response.body)
    h1 = page.css('h1').first
    Rails.logger.debug("$$$ h1: #{h1.inspect}")
    assert h1.text.include?('Nutrients Listing')
    # make a hash of all links on the page
    page_links = page.css('a')
    nutrients_count = Nutrient.all.count
    assert_equal(4+nutrients_count, page_links.count)
    link_map = page_links.map{|a| [a.text, a['href']]}.to_h
    Rails.logger.debug("link_map: #{link_map.inspect}")
    assert_match("/nutrients/new",link_map['New nutrient']) # has New Nutrients link
    assert_match("/foods",link_map['Foods Listing']) # has Foods Listing link
    assert_match("/",link_map['Home']) # has Nutrients Listing link
    assert_match("/signout",link_map['Sign Out']) # has Sign Out link

  end

  test "should get new" do
    get new_nutrient_url
    assert_response :success
  end

  test "should create nutrient" do
    assert_difference("Nutrient.count") do
      @new_nutrient = FactoryBot.build(:nutrient)
      post nutrients_url, params: { nutrient: { desc: @new_nutrient.desc, id: @new_nutrient.id, name: @new_nutrient.name, usda_ndb_num: @new_nutrient.usda_ndb_num } }
    end

    assert_redirected_to nutrient_url(Nutrient.last)
  end

  test "should show nutrient" do
    get nutrient_url(@nutrient)
    assert_response :success
  end

  test "should get edit" do
    get edit_nutrient_url(@nutrient)
    assert_response :success
  end

  test "should update nutrient" do
    patch nutrient_url(@nutrient), params: { nutrient: { desc: @nutrient.desc, id: @nutrient.id, name: @nutrient.name, usda_ndb_num: @nutrient.usda_ndb_num } }
    assert_redirected_to nutrient_url(@nutrient)
  end

  test "should destroy nutrient" do
    assert_difference("Nutrient.count", -1) do
      delete nutrient_url(@nutrient)
    end

    assert_redirected_to nutrients_url
  end
end
