# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require "application_system_test_case"

class NutrientsTest < ApplicationSystemTestCase
  setup do
    @nutrient = nutrients(:one)
  end

  test "visiting the index" do
    visit nutrients_path
    assert_selector "h1", text: "Nutrients"
  end

  test "should create nutrient" do
    visit nutrients_path
    click_on "New nutrient"

    fill_in "Desc", with: @nutrient.desc
    fill_in "Id", with: @nutrient.id
    fill_in "Name", with: @nutrient.name
    fill_in "Usda ndb num", with: @nutrient.usda_ndb_num
    click_on "Create Nutrient"

    assert_text "Nutrient was successfully created"
    click_on "Back"
  end

  test "should update Nutrient" do
    visit nutrient_path(@nutrient)
    click_on "Edit this nutrient", match: :first

    fill_in "Desc", with: @nutrient.desc
    fill_in "Id", with: @nutrient.id
    fill_in "Name", with: @nutrient.name
    fill_in "Usda ndb num", with: @nutrient.usda_ndb_num
    click_on "Update Nutrient"

    assert_text "Nutrient was successfully updated"
    click_on "Back"
  end

  test "should destroy Nutrient" do
    visit nutrient_path(@nutrient)
    click_on "Destroy this nutrient", match: :first

    assert_text "Nutrient was successfully destroyed"
  end
end
