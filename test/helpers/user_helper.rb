
# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

# method name leading with assert in case error in method, minitest will return the calling line number
  def assert_redirected_to_sign_in()
    assert_response 302
    # assert_redirected_to(new_user_session_url)
    assert_redirected_to('/users/sign_in')
  end

  def assert_redirected_root_to_sign_in()
    assert_response 302
    assert_redirected_to('/')
    get root_url
    assert_response 302
    # assert_redirected_to(new_user_session_url)
    assert_redirected_to('/users/sign_in')
  end
