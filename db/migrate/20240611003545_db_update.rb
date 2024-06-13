class DbUpdate < ActiveRecord::Migration[7.1]
  def up
    
    create_table 'alternates' do |t|
      t.integer 'parent_food_id', null: false
      t.integer 'food_id', null: false
      t.float 'proportion_of_parent', default: 1.0, null: false
      t.boolean 'active', default: true, null: false
      t.index ['parent_food_id'], name: 'ix_alternates_on_parent_food_id'
      t.index ['food_id'], name: 'ix_alternates_on_food_id'
    end

    create_table 'ingredients' do |t|
      t.integer 'parent_food_id', null: false
      t.integer 'food_id', null: false
      t.string 'lu_unit_code', null: false
      t.float 'portion_amount', null: false
      t.string 'alt_food_ids_json'
      t.boolean 'active', default: true, null: false
      t.index ['parent_food_id'], name: 'ix_ingredients_on_parent_food_id'
      t.index ['food_id'], name: 'ix_ingredients_on_food_id'
    end

    create_table 'goals' do |t|
      t.integer 'user_id', null: false
      t.string 'goal_name', null: false
      t.text 'goal_description', default: '', null: false
      t.integer 'nutrient_id'
      t.integer 'food_id'
      t.integer "usda_food_cat_id"
      t.integer 'lu_unit_code', null: false
      t.float 'min_alert_amount'
      t.float 'min_warn_amount'
      t.float 'min_good_amount'
      t.float 'max_good_amount'
      t.float 'max_warn_amount'
      t.float 'max_alert_amount'
      t.boolean 'active', default: true, null: false
      t.index ['user_id'], name: 'ix_goals_on_user_id'
      t.index ['goal_name'], name: 'ix_goals_on_goal_name'
      t.index ['nutrient_id'], name: 'ix_goals_on_nutrient_id'
      t.index ['food_id'], name: 'ix_goals_on_food_id'
    end

    create_table 'calendar_items' do |t|
      t.integer 'user_id', null: false
      t.string 'title', null: false
      t.string 'description', default: '', null: false
      t.integer 'lu_cal_event_type', null: false
      t.integer 'year'
      t.integer 'month'
      t.integer 'sequence'
      t.integer 'day'
      t.integer 'hr24'
      t.integer 'min'
      t.integer 'food_id'
      t.string 'lu_unit_code'
      t.float 'portion'
      t.boolean 'active', default: true, null: false
      t.index ['user_id'], name: 'ix_cal_items_on_user_id'
      t.index ['title'], name: 'ix_cal_items_on_title'
      t.index ['lu_cal_event_type'], name: 'ix_cal_items_on_event_type'
      t.index ['food_id'], name: 'ix_cal_items_on_food_id'
      t.index ['lu_unit_code'], name: 'ix_cal_items_on_lu_unit_code'
    end
  end

  def down
    drop_table 'alternates' if Alternate.table_exists?
    drop_table 'ingredients' if Ingredient.table_exists?
    drop_table 'goals' if Goal.table_exists?
    drop_table 'calendar_items' if CalendarItem.table_exists?
  end
end
