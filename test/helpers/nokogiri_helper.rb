# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

###
### this file includes some helper assert functions to work within minitest.
### the 'assert_select_has' function will do a variety of common validations on the test pages select statement, such as: checking the number of options, or checking the selected / displayed option
### the 'assert_page_headers' function will validate all of the headers for the the diet_support applicaion
### the 'assert_link_has' function will match selected values with the page that the link points to.

### Function to do assertions on a select tag with options (by params passed) in controller tests
### For Example:
### if the test Results in a page that has the the following html:
# <select id="portion_unit">
#  <option value="g">gram</option>
#  <option label="mg" value="mg" selected>milligram</option>
# </select>
### Then the following statement in a test returns true: 
#  assert_select_has(page, '<select_element_id>', {
#   :options_count => 2,
#   :selected_count => 1,
#   :displayed_option => "milligram",
#   :selected => [
#     "mg" => "milligram",
#   ],
#   :match_by_value => true,
#   :match_by_text => true,
#   :debugging => true,
# }
# Note: only matching done will be on params that are passed in the (params) hash
# { :displayed_option => gram } will return false
# { :selected => [ "xxx" => 'milligram'], :match_by_text } will return true
# { :selected => [ "xxx" => 'milligram'], :match_by_value } will return false
def assert_select_has(nokogiri_body, select_id, params)
  selects = nokogiri_body.css("select##{select_id}")
  # Rails.logger.debug("$$$ assert_select_has selects.count: #{selects.count}") if params[:debugging]
  Rails.logger.debug("$$$ assert_select_has - matched select element: #{selects.first}") if params[:debugging]
  Rails.logger.debug("$$$ assert_select_has - matched select count: #{selects.count}") if params[:debugging]
  assert_equal(1, selects.count, "cannot find a select element with an ID of the parameter 'select_id' (#{select_id.inspect})")
  # match the options count
  options = selects.css('option')
  # Rails.logger.debug("$$$ assert_select_has options[:options_count]: #{params[:options_count]}") if params[:debugging]
  first_option_text = (options.count > 0) ? get_option_text_or_label(options.first) : ''
  # Rails.logger.debug("$$$ assert_select_has first_option_text: #{first_option_text}") if params[:debugging]
  assert_equal(params[:options_count], options.count) if params[:options_count].present?
  # match the selected options count
  selected = selects.css('option[selected]')
  # Rails.logger.debug("$$$ assert_select_has selected.count: #{selected.count}") if params[:debugging]
  first_selected_text = (selected.count > 0) ? get_option_text_or_label(selected.first) : ''
  # Rails.logger.debug("$$$ assert_select_has first_selected_text: #{first_selected_text}") if params[:debugging]
  assert_equal(params[:selected_count], selected.count) if params[:selected_count].present?
  # if selected params are sent, confirm they are in the array of 'selected' options (to match)
  if params[:selected].present? && params[:selected].count > 0
    # match the selected options values and/or names
    # Rails.logger.debug("$$$ assert_select_has options[:selected]: #{params[:selected].inspect}") if params[:debugging]
    selected.each do |sel_node|
      # Rails.logger.debug("$$$ assert_select_has sel_node.css('[value]'): #{sel_node.css('[value]')}") if params[:debugging]
      assert params[:selected].include?(sel_node.css('[value]')) if params[:match_by_value]
      sel_node_text_or_label = get_option_text_or_label(sel_node)
      # Rails.logger.debug("$$$ assert_select_has sel_node_text_or_label: #{sel_node_text_or_label}") if params[:debugging]
      assert params[:selected].include?(sel_node_text_or_label) if params[:match_by_text]
    end
  end
  # confirm the displayed (default or selected) names
  selected_or_first = (selected.count == 0) ? first_option_text : first_selected_text
  # Rails.logger.debug("$$$ assert_select_has selected_or_first: #{selected_or_first}") if params[:debugging]
  assert_equal(params[:displayed_option], selected_or_first) if params[:displayed_option].present?
  # Rails.logger.debug("$$$ selected_or_first: #{selected_or_first.inspect}") if params[:debugging]
  return selected_or_first
end

# function to handle some of the quirkiness of the HTML option tag
# returns the option text, but if label is supplied, will return label
def get_option_text_or_label(option)
  # Rails.logger.debug("$$$ get_option_text_or_label from option: #{option.inspect}")
  ret = option.text
  # Rails.logger.debug("$$$ get_option_text_or_label from option.text: #{ret}")
  if option.css('[label]').present?
    # use the value attribute if supplied (overrides the text)
    ret = option.css('[label]')
    # Rails.logger.debug("$$$ get_option_text_or_label from option label: #{ret}")
  end
  ret
end

# function to validate the page headers (for any page)
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
def assert_page_headers(noko_page, links_hash, params)
  current_food_record = (params[:current_food_record].present?) ? params[:current_food_record] : nil
  debugging_mode = (params[:debugging_mode].present? ? params[:debugging_mode] === true : false)
  Rails.logger.debug("$$$ assert_page_headers")
  if current_food_record.present?
    Rails.logger.debug("$$$ assert_page_headers food present")
    assert_link_has(links_hash, {
      link_text: "#{current_food_record.name} Nutrients",
      link_url: "/nutrients_of_food/#{current_food_record.id}",
      page_title: "Nutrients of Food Listing",
      page_subtitle: "for food:",
      page_subtitle2: current_food_record.name,
    })
  else
    Rails.logger.debug("$$$ assert_page_headers - food not present")
    assert_equal(1, noko_page.css("#food_nutrients_link[class='inactiveLink']").count)
  end
  assert_link_has(links_hash, {
    link_text: "Foods Listing",
    link_url: "/foods",
    page_title: "Foods Listing",
    # :debugging => true,
  })
  assert_link_has(links_hash, {
    link_text: "Nutrients Listing",
    link_url: "/nutrients",
    page_title: "Nutrients Listing",
    # :debugging => true,
  })
  assert_link_has(links_hash, {
    link_text: "Home",
    link_url: "/",
    page_title: "Food Nutrients Home",
    # :debugging => true,
  })
  assert_link_has(links_hash, {
    link_text: "Sign Out",
    link_url: "/signout",
    # :debugging => true,
  })

end

### Function to do assertions on a link tag and the resulting page in controller tests
### For Example:
### if the page returned results in a page that has the the following html:
# <a href="LinkURL">LinkText</a>
### and if the link were to be clicked (in the test) and it resulted in the following html: 
# <html>
#   <head><title>PageTitleText</title></head>
#   <body><h1>AppTitleText</h1><h2>SubtitleText<br/>Subtitle2Text</h2></body>
# </html>
### Then the following statement in a test returns true: 
# links_hash = get_links_hashes(page)
# assert_link_has(links_hash, {
#   :link_text => 'LinkText',
#   :link_url => 'LinkURL',
#   :match_by_text => true, # default, not needed to be explicitly stated
#   :match_by_url => true, # only needed when there are duplicate link texts, note: non-GET urls can cause duplicate URLs
#   :link_has_classes => "class1, class2"
#   :link_hasnt_classes => "class3, class4"
#   :link_has_method => "delete"
#   :page_title => "PageTitleText",
#   :page_subtitle => "SubtitleText",
#   :page_subtitle2 => "Subtitle2Text",
#   :not_page_title => "NotPageTitleText" # to confirm page has changed, etc.
#   :debugging => true,
# }
# only matching done will be on params that are passed
def assert_link_has(links_hash, params)
  # Rails.logger.debug("$$$ assert_link_has params[:debugging]: #{params[:debugging]}")

  debug_mode = (params[:debugging] && params[:debugging] == true) ? true : false

  # Rails.logger.debug("$$$ assert_link_has links_hash: #{JSON.pretty_generate(links_hash)}") if debug_mode
  Rails.logger.debug("$$$ assert_link_has params: #{JSON.pretty_generate(params)}") #if debug_mode

  # Check to make sure the URL and Link Text match
  # if params[:match_by_url].present? && (params[:match_by_url] == true || params[:match_by_url] == 'true')
  # default to look up links by href first, only do by text if specified in params
  matched_item = nil
  if params[:match_by_text].present? && (params[:match_by_text] == true || params[:match_by_text] == 'true')
    # confirm the link text passed in the params points to the url passed in the params
    # uses the by_text hash created in get_links_hashes to match them up
    Rails.logger.debug("$$$ Match by Text, to see if lookup of params[:link_text] match params[:link_url]") if debug_mode
    assert(links_hash[:by_text][params[:link_text]].present?, "lookup of text: #{params[:link_text]} does not exist")
    assert(links_hash[:by_text][params[:link_text]].count > 0, "lookup of text: #{params[:link_text]} [:href] does not exist")
    matched, matched_item = in_by_text_hash(links_hash, params[:link_text], params[:link_url], debug_mode)
    assert(matched, "lookup of link text #{params[:link_text]} does not have url: #{params[:link_url]}")
  else
    # This is the default, to look find the Link Text for an href (in the anchor tags on the page)
    # confirm the link url passed in the params points to the text passed in the params
    # uses the by_href hash created in get_links_hashes to match them up
    # ?? Rails.logger.debug("$$$ Match by URL, to see if params[:link_url] match params[:link_url]") if debug_mode
    # ?? assert_equal(params[:link_url], links_hash[:by_text][params[:link_text]], 'link text lookup does not match link url')
    Rails.logger.debug("$$$ Match by URL, to see if lookup of params[:link_url] match params[:link_text]") if debug_mode
    # confirm links hash by href has a value matching the link_url param
    assert(links_hash[:by_href][params[:link_url]].present?, "lookup of link url: #{params[:link_url]} does not exist")
    assert(links_hash[:by_href][params[:link_url]].count > 0, "lookup of link url: #{params[:link_url]} has no items")
    matched, matched_item = in_by_href_hash(links_hash, params[:link_url], params[:link_text], debug_mode)
    assert(matched, "lookup of link url #{params[:link_url]} does not have text: #{params[:link_text]}")
  end

  if params[:page_title].present? || params[:page_subtitle].present? || params[:page_subtitle2].present? || params[:not_page_title].present?
    # confirm link goes to where we expect it
    if matched_item[:method] == 'delete'
      delete(matched_item[:href])   # TODO: should we be doing this delete here?
    else
      get(matched_item[:href])
    end
    new_page = Nokogiri::HTML.fragment(response.body)
    if response.status == 200
      # good
    elsif response.status == 302
      redir_page = Nokogiri::HTML.fragment(response.body)
      redir_url = redir_page.css('a').first.attribute('href').text
      Rails.logger.debug("%%% redir_url: #{redir_url.inspect}")
      get(redir_url)
      assert_response :success
    end
    new_page = Nokogiri::HTML.fragment(response.body)
    Rails.logger.debug("$$$ Match by URL, got to page: #{new_page.css('title').text}") if debug_mode
    assert_equal params[:page_title], new_page.css('title').text, "page title #{params[:page_title]} does not match #{new_page.css('title').text}" if params[:page_title].present?
    if params[:page_subtitle].present?
      h2 = new_page.css('h2').first
      Rails.logger.debug("$$$ Match by URL, to see if params[:link_url] match params[:link_text]") if debug_mode
      assert h2.text.include?(params[:page_subtitle]), "page subtitle #{params[:page_subtitle]} is not contained in #{h2.text}"
      if params[:page_subtitle2].present?
        Rails.logger.debug("$$$ Match by URL, to see if params[:link_url] match params[:link_text]") if debug_mode
        assert h2.text.include?(params[:page_subtitle2]), "page subtitle2 #{params[:page_subtitle2]} is not contained in #{h2.text}"
      end
    end
    assert_not_equal params[:not_page_title], new_page.css('title').text, "page title #{params[:not_page_title]} should not match #{new_page.css('title').text}" if params[:not_page_title].present?
  elsif params[:link_has_classes].present?
    params[:link_has_classes].split(/[\s,,,;]/).each do |cls| # split on whitespace, comma, and/or semicolon
      # assert anchor tag has all of the classes specified
      assert matched_item[:class].include?(cls.strip())
    end
  elsif params[:link_hasnt_classes].present?
    params[:link_hasnt_classes].split(/[\s,,,;]/).each do |cls| # split on whitespace, comma, and/or semicolon
      # assert anchor tag has none of the classes specified
      assert_not matched_item[:class].include?(cls.strip())
    end
  end
  Rails.logger.debug("*** successfully finished 'assert_link_has' function.")
end

def in_by_text_hash(links_hash, link_text, link_url)
  links_hash[:by_text][link_text].each do |page_link|
    Rails.logger.debug("$$$ page_link: #{page_link.inspect}")
    return true if page_link[:href].include?(link_url)
  end
  Rails.logger.debug("$$$ link_text not found: #{link_text.inspect}")
  return false, {}
end

def in_by_href_hash(links_hash, link_url, link_text, debug_mode = false)
  Rails.logger.debug("$$$ in_by_href_hash: #{link_url} points to page with title: #{link_text}")
  # ToDo: confirm we need a loop here (will there be duplicate URLs on a page?)
  debug_all_links = []
  links_hash[:by_href][link_url].each do |page_link|
    debug_all_links << "#{page_link[:text]}, " if debug_mode
    Rails.logger.debug("$$$ page_link: #{page_link.inspect}")
    return true, page_link if page_link[:href].include?(link_url)
  end
  Rails.logger.debug("$$$ page_link not found: #{link_url.inspect} in #{debug_all_links.inspect}")
  return false, {}
end

# Get the links on page hashes (:by_text, :by_href, and :count) within one parent hash
def get_links_hashes(noko_page)
  # create a hash whose children are hashes pointing to an array
  # top level is to choose the hash to lookup either by 'link text' or by 'link href'
  # second level is the hash to return an array of matching items (by 'link text' or by 'link href')
  ret = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = []} }
  # only count links in header and main sections, not the footer
  page_links = noko_page.css('header a', 'section a')
  # ret[:by_text] = page_links.map{|a| [a.text, "#{a['href']}"]}.to_h
  # allow multiple items to be stored for duplicated link text values (hash of arrays)
  page_links.each do |a|
    link_item = {
      text: a.text,
      href: a['href'],
      class: a['class'],
      method: a['data-turbo-method']
    }
    ret[:by_text][a.text] << link_item # NOTE: appends to an automatically created array if nothing there yet
    ret[:by_href][a['href']] << link_item # NOTE: appends to an automatically created array if nothing there yet
  end
  ret[:count] = page_links.count
  return ret
end

# Function to do assertions on a link tag (by params passed) in controller tests
# example:
# element: <input type="hidden" id="input_id_attr" value="input_value_attr" />
# usage: e.g. all params used, returns true, params:
# {
#   :hidden_field_id => "hidden_field_id"
#   :debugging => "true",
# }
def get_input_hidden_field_value(noko_page, params)
  debug_mode = (params[:debugging] && params[:debugging] == true) ? true : false
  css_str = "input##{params[:hidden_field_id]}"
  Rails.logger.debug("$$$ css_str: #{css_str}") if debug_mode
  hidden_field = noko_page.css(css_str)
  Rails.logger.debug("$$$ get_input_hidden_field_value hidden_field: #{hidden_field.inspect}") if debug_mode
  Rails.logger.debug("$$$ get_input_hidden_field_value hidden_field.attr('value'): #{hidden_field.attr('value').inspect}") if debug_mode
  Rails.logger.debug("$$$ get_input_hidden_field_value hidden_field.attr('value').to_s: #{hidden_field.attr('value')}") if debug_mode
  return hidden_field.attr('value').to_s
end

# output current page from nokogiri to temp file and list ilename in log
# e.g. page = Nokogiri::HTML.fragment(response.body)
#      save_noko_page(page, "GetFoodIndexListing")
# debug log shows: !!! - page output for GetFoodIndexListing = /media/dave/TowerData1/rails/diet_support/tmp/test_html/24-02-16-13-46-59-GetFoodIndexListing.html
def save_noko_page(noko_page, state_desc)
  # directory and file name with timestamp and state description
  fname = Time.now().strftime("%y-%m-%d-%H-%M-%S") + "-" + state_desc + '.html'
  dfname = "#{Rails.root}/tmp/test_html/#{fname}"
  # make sure the directory exists before writing to the file
  dir = File.dirname(dfname)
  FileUtils.mkdir_p(dir) unless File.directory?(dir)
  # write the nokogiri html page out to file
  File.open(dfname, 'w') do |f|
    f.write(noko_page.inner_html)
  end
  # display the filename to the log
  Rails.logger.debug("!!! - page output for: #{state_desc} is located at: #{dfname}")
end

