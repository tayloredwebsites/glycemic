require "test_helper"
require "helpers/user_helper"

class HomeControllerTests
  class ExistingUserTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include Capybara::DSL

    setup do
      @user = FactoryBot.create(:user)
    end

    # called after every single test
    teardown do
      # # when controller is using cache it may be a good idea to reset it afterwards
      # Rails.cache.clear
    end

    test "user not signed in can sign_in and sign_out" do

      # go to sign in page
      get new_user_session_url
      assert_response 200
      # see nokogiri docs at https://nokogiri.org/rdoc/ (use search)
      page = Nokogiri::HTML.fragment(response.body)
      h2 = page.css('h2').first
      assert h2.text.include?('Log in')
      # confirm we have all the fields necessary
      assert_equal(1, page.css('#user_email').count)
      assert_equal(1, page.css('#user_password').count)

      # Sign in as @user
      sign_in @user
      assert_response 200

      # sign out
      delete destroy_user_session_path
      assert_redirected_root_to_sign_in()


    end

    test "Unlock user with 'Didn't receive unlock instructions?' link" do

      # user can sign in when not locked
      sign_in @user
      get root_url
      assert_response 200

      # sign out
      sign_out @user
      get root_url
      assert_redirected_to_sign_in()

      # lock user
      @user.locked_at = Time.now
      @user.save
      raise "unable to lock user" if @user.errors.count > 0
      Rails.logger.debug("after lock - @user.locked_at: #{@user.locked_at}")
      Rails.logger.debug("after lock - @user.unlock_token: #{@user.unlock_token}")

      # iuser cannot sign in when locked
      sign_in @user
      get root_url
      assert_redirected_to_sign_in()

      # confirm user gets email with unlock instructions
      get new_user_unlock_url
      assert_response 200
      page = Nokogiri::HTML.fragment(response.body)
      h2 = page.css('h2').first
      assert h2.text.include?('Resend unlock instructions')

      # confirm we have all the fields necessary
      assert_equal(1, page.css('#user_email').count)
      assert_equal(1, page.css('input[value="Resend unlock instructions"]').count)
      assert_equal(2, page.css('input').count)
      # TODO: simulate the unlock post message - unlock token seems to be encrypted
      # do the post that would be in the unlock email
      @user.reload
      Rails.logger.debug("after lock - @user.locked_at: #{@user.locked_at}")
      Rails.logger.debug("after lock - @user.unlock_token: #{@user.unlock_token}")
      Rails.logger.debug("post the unlock token: #{@user.unlock_token}")
      Rails.logger.debug("@token?: #{defined?(@token) ? @token.inspect : "@token not defined"}")

      assert_emails 1 do
        post "/users/unlock?unlock_token=#{@user.unlock_token}", params: {
          "user"=>{
            "email"=>@user.email,
          },
          "commit"=>"Resend unlock instructions"
        }
      end
      assert_redirected_to_sign_in()

      mail = ActionMailer::Base.deliveries.last
      # Rails.logger.debug("mail.body.raw_source: #{defined?(mail.body.raw_source) ? mail.body.raw_source.inspect : "mail not defined"}")
      mail_message_body_text = defined?(mail.body.raw_source) ? mail.body.raw_source.inspect : ""
      # Rails.logger.debug("mail_message_body_text: #{mail_message_body_text.inspect}")
      mail_body_html = Nokogiri::HTML.fragment(mail_message_body_text)
      href = mail_body_html.css('a').first.attribute('href').text
      # Rails.logger.debug("href: #{href.inspect}")
      token = href.split('\"')[1].split('=')[1]
      # Rails.logger.debug("token: #{token.inspect}")
      raise "unable to obtain token from email" if token.blank?

      get "/users/unlock?unlock_token=#{token}"

      @user.reload
      assert_nil(@user.locked_at)
      assert_nil(@user.unlock_token)

      # Sign in as @user
      sign_in @user
      get root_url
      assert_response 200
    end

  end

  class UnconfirmedUserTest < ActionDispatch::IntegrationTest
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

    test "User confirmation with 'Didn't receive confirmation instructions?' link" do
      get new_user_confirmation_url
      assert_response 200
      page = Nokogiri::HTML.fragment(response.body)
      h2 = page.css('h2').first
      assert h2.text.include?('Resend confirmation instructions')
      # confirm we have the 1 input field plus 1 for the "Resend Confirmation instruction" button
      assert_equal(1, page.css('#user_email').count)
      assert_equal(1, page.css('input[value="Resend confirmation instructions"]').count)
      assert_equal(2, page.css('input').count)
      assert_emails 1 do
        post '/users/confirmation', params: {
          "user"=>{
            "email"=>@unconfirmed_user.email,
          },
          "commit"=>"Resend confirmation instructions"
        }
      end
      assert_redirected_to_sign_in()

    end

  end

  class NoUserUserTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = FactoryBot.create(:user)
    end

    # called after every single test
    teardown do
      # # when controller is using cache it may be a good idea to reset it afterwards
      # Rails.cache.clear
    end

    test "user can sign up with 'Sign up' link" do

      # go to sign in page
      get new_user_session_url
      assert_response 200
      # see nokogiri docs at https://nokogiri.org/rdoc/ (use search)
      page = Nokogiri::HTML.fragment(response.body)
      h2 = page.css('h2').first
      assert h2.text.include?('Log in')
      assert_equal(1, page.css('a:contains("Sign up")').count)

      get new_user_registration_path
      assert_response 200
      page = Nokogiri::HTML.fragment(response.body)
      h2 = page.css('h2').first
      assert h2.text.include?('Sign up')
      # confirm we have the 3 input fields plus 1 for the sign up button
      assert_equal(1, page.css('#user_email').count)
      assert_equal(1, page.css('#user_password').count)
      assert_equal(1, page.css('#user_password_confirmation').count)
      assert_equal(1, page.css('input[value="Sign up"]').count)
      assert_equal(4, page.css('input').count)

      assert_emails 1 do
        post '/users', params: {
          "user"=>{
            "email"=>"test1@sample.org",
            "password"=>"password",
            "password_confirmation"=>"password"
          },
          "commit"=>"Sign up"
        }
      end
      assert_redirected_root_to_sign_in()

      # confirm last user added was this user
      last_user = User.last
      assert_equal("test1@sample.org", last_user.email)
      assert_nil(last_user.confirmed_at)

      # sign in using devise fails - not confirmed yet
      sign_in @user

      # send confirmation link
      post "/users/confirmation?confirmation_token=#{last_user.confirmation_token}"
      assert_response 200

      # sign in using devise
      sign_in @user

      # sign out
      # sign_out @user # sign out using devise
      delete destroy_user_session_path
      assert_redirected_root_to_sign_in()

    end

    test "existing user can reset password with 'Forgot your password?' link" do
      skip("fill this in")
    end

  end

end
