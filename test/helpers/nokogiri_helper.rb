
# function to do assertions on a select tag with options (by params passed) in controller tests
def assert_select_has(nokogiri_body, select_id, params)
  # example: <select id="portion_unit">
  #  <option value="g">gram</option>
  #  <option label="mg" value="mg" selected>milligram</option>
  # </select>
  # e.g. all params used, returns true: {
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
  # only matching done will be on params that are passed
  # { :displayed_option => gram } will return false
  # { :selected => [ "xxx" => 'milligram'], :match_by_text } will return true
  # { :selected => [ "xxx" => 'milligram'], :match_by_value } will return false

  selects = nokogiri_body.css("select##{select_id}")
  # Rails.logger.debug("$$$ assert_select_has selects.count: #{selects.count}") if params[:debugging]
  Rails.logger.debug("$$$ assert_select_has - matched select element: #{selects.first}") if params[:debugging]
  Rails.logger.debug("$$$ assert_select_has - matched select count: #{selects.count}") if params[:debugging]
  assert_equal(1, selects.count)
  # match the options count
  options = selects.css('option')
  # Rails.logger.debug("$$$ assert_select_has options[:options_count]: #{params[:options_count]}") if params[:debugging]
  first_option_text = options.count > 0 ? get_option_text_or_label(options.first) : ''
  # Rails.logger.debug("$$$ assert_select_has first_option_text: #{first_option_text}") if params[:debugging]
  assert_equal(params[:options_count], options.count) if params[:options_count].present?
  # match the selected options count 
  selected = selects.css('option[selected]')
  # Rails.logger.debug("$$$ assert_select_has selected.count: #{selected.count}") if params[:debugging]
  first_selected_text = selected.count > 0 ? get_option_text_or_label(selected.first) : ''
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

def assert_page_headers(noko_page, links_hash)
  Rails.logger.debug("$$$ assert_page_headers")
  if @food.present?
    Rails.logger.debug("$$$ assert_page_headers food present")
    assert_link_has(links_hash, {
      :link_text => "#{@food.name} Nutrients",
      :link_url => "/nutrients_of_food/#{@food.id}",
      :page_title => "Nutrients of Food Listing",
      :page_subtitle => "for food:",
      :page_subtitle2 => @food.name,
    })
  else
    Rails.logger.debug("$$$ assert_page_headers - food not present")
    assert_equal(1, noko_page.css("#food_nutrients_link[class='inactiveLink']").count)
  end
  assert_link_has(links_hash, {
    :link_text => "Foods Listing",
    :link_url => "/foods",
    :page_title => "Foods Listing",
    # :debugging => true,
  })
  assert_link_has(links_hash, {
    :link_text => "Nutrients Listing",
    :link_url => "/nutrients",
    :page_title => "Nutrients Listing",
    # :debugging => true,
  })
  assert_link_has(links_hash, {
    :link_text => "Home",
    :link_url => "/",
    :page_title => "Food Nutrients Home",
    # :debugging => true,
  })
  assert_link_has(links_hash, {
    :link_text => "Sign Out",
    :link_url => "/signout",
    # :debugging => true,
  })

end

# function to do assertions on a link tag (by params passed) in controller tests
def assert_link_has(links_hash, params)
  Rails.logger.debug("$$$ assert_link_has")
  # example:
  #   Link: <a href="LinkURL">LinkText</a>
  #   Page at LinkURL:
  #     <html>
  #       <head><title>PageTitleText</title></head>
  #       <body><h1>AppTitleText</h1><h2>SubtitleText<br/>Subtitle2Text</h2></body>
  #     </html>
  # e.g. all params used, returns true:
  # params: {
  #   :link_text => 'LinkText',
  #   :link_url => 'LinkURL',
  #   :match_by_text => true, # only needed when there are multiple links to the same url on a page with different link text
  #   :page_title => "PageTitleText",
  #   :page_subtitle => "SubtitleText",
  #   :page_subtitle2 => "Subtitle2Text",
  #   :debugging => true,
  # }
  # only matching done will be on params that are passed

  debug_mode = (params[:debugging] && params[:debugging] == true) ? true : false

  Rails.logger.debug("$$$ assert_link_has links_hash: #{JSON.pretty_generate(links_hash)}") if debug_mode

  # Check to make sure the URL and Link Text match
  if params[:match_by_text].present? && params[:match_by_text] == true
    # confirm the link text passed in the params points to the url passed in the params
    # uses the links_hash created in get_links_hashes to match them up
    Rails.logger.debug("$$$ Match by Text, to see if params[:link_text] match params[:link_url]") if debug_mode
    assert_equal(params[:link_url], links_hash[:by_text][params[:link_text]], 'link text lookup does not match link url')
  else
    # This is the default, to look find the Link Text for an href (in the anchor tags on the page)
    # confirm the url passed in the params points to the text passed in the params
    # uses the links_url child hash created in get_links_hashes to match them up
    Rails.logger.debug("$$$ Match by URL, to see if params[:link_url] match params[:link_text]") if debug_mode
    assert(links_hash[:by_href][params[:link_url]].present?, "lookup of text: #{params[:link_text]} matching url: #{params[:link_url]} was not found")
    assert(
      links_hash[:by_href][params[:link_url]].include?(
        params[:link_text]
      ), "link url lookup found #{params[:link_text]} does not include text: #{params[:link_text]}"
    )
  end

  if params[:page_title].present? || params[:page_subtitle].present? || params[:page_subtitle2].present?
    # confirm link goes to where we expect it
    get(params[:link_url])
    assert_response :success
    new_page = Nokogiri::HTML.fragment(response.body)
    assert_equal params[:page_title], new_page.css('title').text, "page title #{params[:page_title]} does not match #{new_page.css('title').text}"
    if params[:page_subtitle].present?
      h2 = new_page.css('h2').first
      # Rails.logger.debug("$$$ Match by URL, to see if params[:link_url] match params[:link_text]") if debug_mode
      assert h2.text.include?(params[:page_subtitle]), "page subtitle #{params[:page_subtitle]} is not contained in #{h2.text}"
      if params[:page_subtitle2].present?
        # Rails.logger.debug("$$$ Match by URL, to see if params[:link_url] match params[:link_text]") if debug_mode
        assert h2.text.include?(params[:page_subtitle2]), "page subtitle2 #{params[:page_subtitle2]} is not contained in #{h2.text}"
      end
    end
  end
end
    
  # get the links on page hashes (:by_text, :by_href, and :count) within one parent hash
def get_links_hashes(noko_page)
  ret = Hash.new
  page_links = noko_page.css('a')
  ret[:by_text] = page_links.map{|a| [a.text, a['href']]}.to_h
  # Rails.logger.debug("title_map: #{title_map.inspect}")
  ret[:by_href] = page_links.map{|a| [ a['href'], a.text]}.to_h
  ret[:count] = page_links.count
  return ret
end
  
# function to do assertions on a link tag (by params passed) in controller tests
def get_input_hidden_field_value(noko_page, params)
  # example:
  # element: <input type="hidden" id="input_id_attr" value="input_value_attr" />
  # usage: e.g. all params used, returns true, params:
  # {
  #   :hidden_field_id => "hidden_field_id"
  #   :debugging => "true",
  # }
  debug_mode = (params[:debugging] && params[:debugging] == true) ? true : false
  css_str = "input##{params[:hidden_field_id]}"
  Rails.logger.debug("$$$ css_str: #{css_str}") if debug_mode
  hidden_field = noko_page.css(css_str)
  Rails.logger.debug("$$$ get_input_hidden_field_value hidden_field: #{hidden_field.inspect}") if debug_mode
  Rails.logger.debug("$$$ get_input_hidden_field_value hidden_field.attr('value'): #{hidden_field.attr('value').inspect}") if debug_mode
  Rails.logger.debug("$$$ get_input_hidden_field_value hidden_field.attr('value').to_s: #{hidden_field.attr('value').to_s}") if debug_mode
  return hidden_field.attr('value').to_s
end

