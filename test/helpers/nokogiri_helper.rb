
# function to do assertions (by params passed) on a select tag with options
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
  #   :debugging => false,
  # }
  # only matching done will be on params that are passed
  # { :displayed_option => gram } will return false
  # { :selected => [ "xxx" => 'milligram'], :match_by_text } will return true
  # { :selected => [ "xxx" => 'milligram'], :match_by_value } will return false

  selects = nokogiri_body.css("select##{select_id}")
  # Rails.logger.debug("$$$ assert_select_has selects.count: #{selects.count}") if params[:debugging]
  Rails.logger.debug("$$$ assert_select_has selects.first: #{selects.first}") if params[:debugging]
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
