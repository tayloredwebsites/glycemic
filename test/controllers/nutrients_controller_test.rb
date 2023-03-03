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
    @nutrients = [@nutrient1, @nutrient2]
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
    assert_at_page(page, 'Nutrients Listing')
    # make a hash of all links on the page
    linksH = get_links_hashes(page)
    # make sure we have links for the header, three for each nutrient, and one at the bottom
    nutrients_count = Nutrient.all.count
    assert_equal(5+nutrients_count*2+1, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, linksH)

    @nutrients.each do |nut|
      assert_link_has(linksH, {
        :link_text => "Edit",
        :link_url => "/nutrients/#{nut.id}/edit",
        :page_title => "Edit Nutrient Page",
        :page_subtitle => "for nutrient: #{nut.name}"
      })
      assert_link_has(linksH, {
        :link_text => "Delete",
        :link_url => "/nutrients/#{nut.id}",
        # TODO: validate the "Are you sure?" alert
        # TODO: validate the delete page is linked to properly
    })
    end
    assert_link_has(linksH, {
      :link_text => "New Nutrient",
      :link_url => "/nutrients/new",
      :page_title => "New Nutrient Page",
      :page_subtitle => "New Nutrient Page",
    })

  end

  test "should get new" do
    get new_nutrient_url
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "New Nutrient Page", "New Nutrient Page")
    linksH = get_links_hashes(page)
    # make sure we have links for the header
    assert_equal(5, linksH[:count])
    # make sure that we have the correct links on the page
    assert_page_headers(page, linksH)

    # confirm all appropriate form fields exist
    assert_equal(1, page.css("form[action='/nutrients']").count)
    assert_equal(1, page.css('input#nutrient_name').count)
    assert_equal(1, page.css('textarea#nutrient_desc').count)
    assert_equal(1, page.css('input#nutrient_usda_ndb_num').count)
    assert_equal(1, page.css("input[type='submit'][value='Create Nutrient']").count)


  end

  test "should create nutrient" do
    @new_nutrient = FactoryBot.build(:nutrient)
    assert_difference("Nutrient.count", 1, "a nutrient should be created") do
      post nutrients_url, params: {
        nutrient: {
          desc: @new_nutrient.desc,
          id: @new_nutrient.id,
          name: @new_nutrient.name,
          usda_ndb_num: @new_nutrient.usda_ndb_num
        }
      }
    end
    assert_redirected_to nutrient_url(Nutrient.last)
  end

  test "should show nutrient" do
    # TODO: enhance this test if and when show page is enhanced
    get nutrient_url(@nutrient1)
    assert_response :success
  end

  test "should get edit" do
    get edit_nutrient_url(@nutrient1)
    assert_response :success
    page = Nokogiri::HTML.fragment(response.body)
    assert_at_page(page, "Edit Nutrient Page", "Edit Nutrient Page", "for nutrient: #{@nutrient1.name}")
    linksH = get_links_hashes(page)
    # make sure we have links for the header plus 2 extra ones below
    assert_equal(5+2, linksH[:count])
    # make sure that we have the correct links on the page
    @nutrient = @nutrient1.clone # 'assert_page_headers' uses @nutrient to determine if 'Food' Nutrients link should be dim or not.
    assert_page_headers(page, linksH)

    assert_link_has(linksH, {
      :link_text => "New Nutrient",
      :link_url => "/nutrients/new",
      :page_title => "New Nutrient Page",
      :page_subtitle => "New Nutrient Page",
      :debugging => true,
    })
    assert_link_has(linksH, {
      :link_text => "Delete this nutrient",
      :link_url => "/nutrients/#{@nutrient1.id}",
      # TODO: validate the "Are you sure?" alert
      # TODO: validate the delete page is linked to properly
    })
  end

  test "should update nutrient" do
    # patch nutrient_url(@nutrient1), params: { nutrient: { desc: @nutrient1.desc, id: @nutrient1.id, name: @nutrient1.name, usda_ndb_num: @nutrient1.usda_ndb_num } }
    # assert_redirected_to nutrient_url(@nutrient1)
    # save off the original state of the nutrient
    @changed_nutrient = @nutrient1.clone

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


  test "should destroy nutrient" do
    assert_difference("Nutrient.count", -1) do
      delete nutrient_url(@nutrient1)
    end

    assert_redirected_to nutrients_url
  end
end
