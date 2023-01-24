require "test_helper"

class FoodNutrientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_nutrient = food_nutrients(:one)
  end

  test "should get index" do
    get food_nutrients_url
    assert_response :success
  end

  test "should get new" do
    get new_food_nutrient_url
    assert_response :success
  end

  test "should create food_nutrient" do
    assert_difference("FoodNutrient.count") do
      post food_nutrients_url, params: { food_nutrient: { amount: @food_nutrient.amount, amount_unit: @food_nutrient.amount_unit, avg_rec_id: @food_nutrient.avg_rec_id, desc: @food_nutrient.desc, food_id: @food_nutrient.food_id, id: @food_nutrient.id, nutrient_id: @food_nutrient.nutrient_id, portion: @food_nutrient.portion, portion_unit: @food_nutrient.portion_unit, study: @food_nutrient.study, study_weight: @food_nutrient.study_weight } }
    end

    assert_redirected_to food_nutrient_url(FoodNutrient.last)
  end

  test "should show food_nutrient" do
    get food_nutrient_url(@food_nutrient)
    assert_response :success
  end

  test "should get edit" do
    get edit_food_nutrient_url(@food_nutrient)
    assert_response :success
  end

  test "should update food_nutrient" do
    patch food_nutrient_url(@food_nutrient), params: { food_nutrient: { amount: @food_nutrient.amount, amount_unit: @food_nutrient.amount_unit, avg_rec_id: @food_nutrient.avg_rec_id, desc: @food_nutrient.desc, food_id: @food_nutrient.food_id, id: @food_nutrient.id, nutrient_id: @food_nutrient.nutrient_id, portion: @food_nutrient.portion, portion_unit: @food_nutrient.portion_unit, study: @food_nutrient.study, study_weight: @food_nutrient.study_weight } }
    assert_redirected_to food_nutrient_url(@food_nutrient)
  end

  test "should destroy food_nutrient" do
    assert_difference("FoodNutrient.count", -1) do
      delete food_nutrient_url(@food_nutrient)
    end

    assert_redirected_to food_nutrients_url
  end
end
