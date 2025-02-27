# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

# This file should contain all of the LookupTable records.
# The programming in this app (for performance and programming simplicity) usually finds a lookup table by its ID, not by lu_table and lu_id.
# For this to work properly, testing requires that the LookupTable is always loaded consistently to maintain identical autosequenced ID values
# To retain autosequenced ID values, the table it truncated and the identity restarted.
# This should be run in the setup for all tests requiring lookup tables.

# Use this to populate the LookupTables for test, production, and development, so all environments are consistently equal
# - for test environment, within your test (as needed): load "./test/helpers/test_load_lookup_table.rb"
# - for development environment: bin/rails runner LookupTableSeedHash.lookup_table_load development
# - for production environment: bin/rails runner LookupTableSeedHash.lookup_table_load production
module LookupTableSeedHash
  def self.lookup_table_load()

    puts("ARGV: #{ARGV.inspect}")
    puts("validation: #{['development', 'production'].include?(ARGV[0])}")
    if ARGV.length != 1  || !['development', 'production'].include?(ARGV[0])
      puts("Missing  or invalid environment in command line argument")
      puts("Command syntax: bin/rails runner LookupTableSeedHash.lookup_table_load <env>")
      puts("  where <env> is { development, or production }")
      raise "Halt - missing environment command line argument"
    end
  
    # raise 'halt, testing'
    # clear LookupTable and reset identity autoincrement
    ActiveRecord::Base.connection.execute("TRUNCATE lookup_tables RESTART IDENTITY")

    # raise 'halt, testing'

    LookupTableSeedHash::get_hash().each do |h|
      rec = LookupTable.create(h)
    end
    Rails.logger.info("CREATED #{LookupTable.count}")
    
    raise "Halt - invalid LookupTablerecord count" if LookupTable.count != 199
    raise "Halt - invalid LookupTablerecord ids" if LookupTable.last.id != 199
  end
  
  
  def self.get_hash()
    lu_hash =  [
      {lu_table: 'usda_cat', lu_id: '1', lu_code: '100', lu_desc: 'Dairy and Egg Products'},
      {lu_table: 'usda_cat', lu_id: '2', lu_code: '200', lu_desc: 'Spices and Herbs'},
      {lu_table: 'usda_cat', lu_id: '3', lu_code: '300', lu_desc: 'Baby Foods'},
      {lu_table: 'usda_cat', lu_id: '4', lu_code: '400', lu_desc: 'Fats and Oils'},
      {lu_table: 'usda_cat', lu_id: '5', lu_code: '500', lu_desc: 'Poultry Products'},
      {lu_table: 'usda_cat', lu_id: '6', lu_code: '600', lu_desc: 'Soups, Sauces, and Gravies'},
      {lu_table: 'usda_cat', lu_id: '7', lu_code: '700', lu_desc: 'Sausages and Luncheon Meats'},
      {lu_table: 'usda_cat', lu_id: '8', lu_code: '800', lu_desc: 'Breakfast Cereals'},
      {lu_table: 'usda_cat', lu_id: '9', lu_code: '900', lu_desc: 'Fruits and Fruit Juices'},
      {lu_table: 'usda_cat', lu_id: '10', lu_code: '1000', lu_desc: 'Pork Products'},
      {lu_table: 'usda_cat', lu_id: '11', lu_code: '1100', lu_desc: 'Vegetables and Vegetable Products'},
      {lu_table: 'usda_cat', lu_id: '12', lu_code: '1200', lu_desc: 'Nut and Seed Products'},
      {lu_table: 'usda_cat', lu_id: '13', lu_code: '1300', lu_desc: 'Beef Products'},
      {lu_table: 'usda_cat', lu_id: '14', lu_code: '1400', lu_desc: 'Beverages'},
      {lu_table: 'usda_cat', lu_id: '15', lu_code: '1500', lu_desc: 'Finfish and Shellfish Products'},
      {lu_table: 'usda_cat', lu_id: '16', lu_code: '1600', lu_desc: 'Legumes and Legume Products'},
      {lu_table: 'usda_cat', lu_id: '17', lu_code: '1700', lu_desc: 'Lamb, Veal, and Game Products'},
      {lu_table: 'usda_cat', lu_id: '18', lu_code: '1800', lu_desc: 'Baked Products'},
      {lu_table: 'usda_cat', lu_id: '19', lu_code: '1900', lu_desc: 'Sweets'},
      {lu_table: 'usda_cat', lu_id: '20', lu_code: '2000', lu_desc: 'Cereal Grains and Pasta'},
      {lu_table: 'usda_cat', lu_id: '21', lu_code: '2100', lu_desc: 'Fast Foods'},
      {lu_table: 'usda_cat', lu_id: '22', lu_code: '2200', lu_desc: 'Meals, Entrees, and Side Dishes'},
      {lu_table: 'usda_cat', lu_id: '23', lu_code: '2500', lu_desc: 'Snacks'},
      {lu_table: 'usda_cat', lu_id: '24', lu_code: '3500', lu_desc: 'American Indian/Alaska Native Foods'},
      {lu_table: 'usda_cat', lu_id: '25', lu_code: '3600', lu_desc: 'Restaurant Foods'},
      {lu_table: 'usda_cat', lu_id: '26', lu_code: '4500', lu_desc: 'Branded Food Products Database'},
      {lu_table: 'usda_cat', lu_id: '27', lu_code: '2600', lu_desc: 'Quality Control Materials'},
      {lu_table: 'usda_cat', lu_id: '28', lu_code: '1410', lu_desc: 'Alcoholic Beverages'},
      {lu_table: 'wweia_cat', lu_code: '1002', lu_desc: 'Milk, whole'},
      {lu_table: 'wweia_cat', lu_code: '1004', lu_desc: 'Milk, reduced fat'},
      {lu_table: 'wweia_cat', lu_code: '1006', lu_desc: 'Milk, lowfat'},
      {lu_table: 'wweia_cat', lu_code: '1008', lu_desc: 'Milk, nonfat'},
      {lu_table: 'wweia_cat', lu_code: '1202', lu_desc: 'Flavored milk, whole'},
      {lu_table: 'wweia_cat', lu_code: '1204', lu_desc: 'Flavored milk, reduced fat'},
      {lu_table: 'wweia_cat', lu_code: '1206', lu_desc: 'Flavored milk, lowfat'},
      {lu_table: 'wweia_cat', lu_code: '1208', lu_desc: 'Flavored milk, nonfat'},
      {lu_table: 'wweia_cat', lu_code: '1402', lu_desc: 'Milk shakes and other dairy drinks'},
      {lu_table: 'wweia_cat', lu_code: '1404', lu_desc: 'Milk substitutes'},
      {lu_table: 'wweia_cat', lu_code: '1602', lu_desc: 'Cheese'},
      {lu_table: 'wweia_cat', lu_code: '1604', lu_desc: 'Cottage/ricotta cheese'},
      {lu_table: 'wweia_cat', lu_code: '1820', lu_desc: 'Yogurt, regular'},
      {lu_table: 'wweia_cat', lu_code: '1822', lu_desc: 'Yogurt, Greek'},
      {lu_table: 'wweia_cat', lu_code: '2002', lu_desc: 'Beef, excludes ground'},
      {lu_table: 'wweia_cat', lu_code: '2004', lu_desc: 'Ground beef'},
      {lu_table: 'wweia_cat', lu_code: '2006', lu_desc: 'Pork'},
      {lu_table: 'wweia_cat', lu_code: '2008', lu_desc: 'Lamb, goat, game'},
      {lu_table: 'wweia_cat', lu_code: '2010', lu_desc: 'Liver and organ meats'},
      {lu_table: 'wweia_cat', lu_code: '2202', lu_desc: 'Chicken, whole pieces'},
      {lu_table: 'wweia_cat', lu_code: '2204', lu_desc: 'Chicken patties, nuggets and tenders'},
      {lu_table: 'wweia_cat', lu_code: '2206', lu_desc: 'Turkey, duck, other poultry'},
      {lu_table: 'wweia_cat', lu_code: '2402', lu_desc: 'Fish'},
      {lu_table: 'wweia_cat', lu_code: '2404', lu_desc: 'Shellfish'},
      {lu_table: 'wweia_cat', lu_code: '2502', lu_desc: 'Eggs and omelets'},
      {lu_table: 'wweia_cat', lu_code: '2602', lu_desc: 'Cold cuts and cured meats'},
      {lu_table: 'wweia_cat', lu_code: '2604', lu_desc: 'Bacon'},
      {lu_table: 'wweia_cat', lu_code: '2606', lu_desc: 'Frankfurters'},
      {lu_table: 'wweia_cat', lu_code: '2608', lu_desc: 'Sausages'},
      {lu_table: 'wweia_cat', lu_code: '2802', lu_desc: 'Beans, peas, legumes'},
      {lu_table: 'wweia_cat', lu_code: '2804', lu_desc: 'Nuts and seeds'},
      {lu_table: 'wweia_cat', lu_code: '2806', lu_desc: 'Processed soy products'},
      {lu_table: 'wweia_cat', lu_code: '3002', lu_desc: 'Meat mixed dishes'},
      {lu_table: 'wweia_cat', lu_code: '3004', lu_desc: 'Poultry mixed dishes'},
      {lu_table: 'wweia_cat', lu_code: '3006', lu_desc: 'Seafood mixed dishes'},
      {lu_table: 'wweia_cat', lu_code: '3102', lu_desc: 'Bean, pea, legume dishes'},
      {lu_table: 'wweia_cat', lu_code: '3104', lu_desc: 'Vegetable dishes'},
      {lu_table: 'wweia_cat', lu_code: '3202', lu_desc: 'Rice mixed dishes'},
      {lu_table: 'wweia_cat', lu_code: '3204', lu_desc: 'Pasta mixed dishes, excludes macaroni and cheese'},
      {lu_table: 'wweia_cat', lu_code: '3206', lu_desc: 'Macaroni and cheese'},
      {lu_table: 'wweia_cat', lu_code: '3208', lu_desc: 'Turnovers and other grain-based items'},
      {lu_table: 'wweia_cat', lu_code: '3402', lu_desc: 'Fried rice and lo/chow mein'},
      {lu_table: 'wweia_cat', lu_code: '3404', lu_desc: 'Stir-fry and soy-based sauce mixtures'},
      {lu_table: 'wweia_cat', lu_code: '3406', lu_desc: 'Egg rolls, dumplings, sushi'},
      {lu_table: 'wweia_cat', lu_code: '3502', lu_desc: 'Burritos and tacos'},
      {lu_table: 'wweia_cat', lu_code: '3504', lu_desc: 'Nachos'},
      {lu_table: 'wweia_cat', lu_code: '3506', lu_desc: 'Other Mexican mixed dishes'},
      {lu_table: 'wweia_cat', lu_code: '3602', lu_desc: 'Pizza'},
      {lu_table: 'wweia_cat', lu_code: '3702', lu_desc: 'Burgers'},
      {lu_table: 'wweia_cat', lu_code: '3703', lu_desc: 'Frankfurter sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3704', lu_desc: 'Chicken fillet sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3706', lu_desc: 'Egg/breakfast sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3708', lu_desc: 'Other sandwiches (single code)'},
      {lu_table: 'wweia_cat', lu_code: '3720', lu_desc: 'Cheese sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3722', lu_desc: 'Peanut butter and jelly sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3730', lu_desc: 'Seafood sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3802', lu_desc: 'Soups'},
      {lu_table: 'wweia_cat', lu_code: '4002', lu_desc: 'Rice'},
      {lu_table: 'wweia_cat', lu_code: '4004', lu_desc: 'Pasta, noodles, cooked grains'},
      {lu_table: 'wweia_cat', lu_code: '4202', lu_desc: 'Yeast breads'},
      {lu_table: 'wweia_cat', lu_code: '4204', lu_desc: 'Rolls and buns'},
      {lu_table: 'wweia_cat', lu_code: '4206', lu_desc: 'Bagels and English muffins'},
      {lu_table: 'wweia_cat', lu_code: '4208', lu_desc: 'Tortillas'},
      {lu_table: 'wweia_cat', lu_code: '4402', lu_desc: 'Biscuits, muffins, quick breads'},
      {lu_table: 'wweia_cat', lu_code: '4404', lu_desc: 'Pancakes, waffles, French toast'},
      {lu_table: 'wweia_cat', lu_code: '4602', lu_desc: 'Ready-to-eat cereal, higher sugar (>21.2g/100g)'},
      {lu_table: 'wweia_cat', lu_code: '4604', lu_desc: 'Ready-to-eat cereal, lower sugar (=<21.2g/100g)'},
      {lu_table: 'wweia_cat', lu_code: '4802', lu_desc: 'Oatmeal'},
      {lu_table: 'wweia_cat', lu_code: '4804', lu_desc: 'Grits and other cooked cereals'},
      {lu_table: 'wweia_cat', lu_code: '5002', lu_desc: 'Potato chips'},
      {lu_table: 'wweia_cat', lu_code: '5004', lu_desc: 'Tortilla, corn, other chips'},
      {lu_table: 'wweia_cat', lu_code: '5006', lu_desc: 'Popcorn'},
      {lu_table: 'wweia_cat', lu_code: '5008', lu_desc: 'Pretzels/snack mix'},
      {lu_table: 'wweia_cat', lu_code: '5202', lu_desc: 'Crackers, excludes saltines'},
      {lu_table: 'wweia_cat', lu_code: '5204', lu_desc: 'Saltine crackers'},
      {lu_table: 'wweia_cat', lu_code: '5402', lu_desc: 'Cereal bars'},
      {lu_table: 'wweia_cat', lu_code: '5404', lu_desc: 'Nutrition bars'},
      {lu_table: 'wweia_cat', lu_code: '5502', lu_desc: 'Cakes and pies'},
      {lu_table: 'wweia_cat', lu_code: '5504', lu_desc: 'Cookies and brownies'},
      {lu_table: 'wweia_cat', lu_code: '5506', lu_desc: 'Doughnuts, sweet rolls, pastries'},
      {lu_table: 'wweia_cat', lu_code: '5702', lu_desc: 'Candy containing chocolate'},
      {lu_table: 'wweia_cat', lu_code: '5704', lu_desc: 'Candy not containing chocolate'},
      {lu_table: 'wweia_cat', lu_code: '5802', lu_desc: 'Ice cream and frozen dairy desserts'},
      {lu_table: 'wweia_cat', lu_code: '5804', lu_desc: 'Pudding'},
      {lu_table: 'wweia_cat', lu_code: '5806', lu_desc: 'Gelatins, ices, sorbets'},
      {lu_table: 'wweia_cat', lu_code: '6002', lu_desc: 'Apples'},
      {lu_table: 'wweia_cat', lu_code: '6004', lu_desc: 'Bananas'},
      {lu_table: 'wweia_cat', lu_code: '6006', lu_desc: 'Grapes'},
      {lu_table: 'wweia_cat', lu_code: '6008', lu_desc: 'Peaches and nectarines'},
      {lu_table: 'wweia_cat', lu_code: '6009', lu_desc: 'Strawberries'},
      {lu_table: 'wweia_cat', lu_code: '6011', lu_desc: 'Blueberries and other berries'},
      {lu_table: 'wweia_cat', lu_code: '6012', lu_desc: 'Citrus fruits'},
      {lu_table: 'wweia_cat', lu_code: '6014', lu_desc: 'Melons'},
      {lu_table: 'wweia_cat', lu_code: '6016', lu_desc: 'Dried fruits'},
      {lu_table: 'wweia_cat', lu_code: '6018', lu_desc: 'Other fruits and fruit salads'},
      {lu_table: 'wweia_cat', lu_code: '6020', lu_desc: 'Pears'},
      {lu_table: 'wweia_cat', lu_code: '6022', lu_desc: 'Pineapple'},
      {lu_table: 'wweia_cat', lu_code: '6024', lu_desc: 'Mango and papaya'},
      {lu_table: 'wweia_cat', lu_code: '6402', lu_desc: 'Tomatoes'},
      {lu_table: 'wweia_cat', lu_code: '6404', lu_desc: 'Carrots'},
      {lu_table: 'wweia_cat', lu_code: '6406', lu_desc: 'Other red and orange vegetables'},
      {lu_table: 'wweia_cat', lu_code: '6407', lu_desc: 'Broccoli'},
      {lu_table: 'wweia_cat', lu_code: '6409', lu_desc: 'Spinach'},
      {lu_table: 'wweia_cat', lu_code: '6410', lu_desc: 'Lettuce and lettuce salads'},
      {lu_table: 'wweia_cat', lu_code: '6411', lu_desc: 'Other dark green vegetables'},
      {lu_table: 'wweia_cat', lu_code: '6412', lu_desc: 'String beans'},
      {lu_table: 'wweia_cat', lu_code: '6413', lu_desc: 'Cabbage'},
      {lu_table: 'wweia_cat', lu_code: '6414', lu_desc: 'Onions'},
      {lu_table: 'wweia_cat', lu_code: '6416', lu_desc: 'Corn'},
      {lu_table: 'wweia_cat', lu_code: '6418', lu_desc: 'Other starchy vegetables'},
      {lu_table: 'wweia_cat', lu_code: '6420', lu_desc: 'Other vegetables and combinations'},
      {lu_table: 'wweia_cat', lu_code: '6430', lu_desc: 'Fried vegetables'},
      {lu_table: 'wweia_cat', lu_code: '6432', lu_desc: 'Coleslaw, non-lettuce salads'},
      {lu_table: 'wweia_cat', lu_code: '6489', lu_desc: 'Vegetables on a sandwich'},
      {lu_table: 'wweia_cat', lu_code: '6802', lu_desc: 'White potatoes, baked or boiled'},
      {lu_table: 'wweia_cat', lu_code: '6804', lu_desc: 'French fries and other fried white potatoes'},
      {lu_table: 'wweia_cat', lu_code: '6806', lu_desc: 'Mashed potatoes and white potato mixtures'},
      {lu_table: 'wweia_cat', lu_code: '7002', lu_desc: 'Citrus juice'},
      {lu_table: 'wweia_cat', lu_code: '7004', lu_desc: 'Apple juice'},
      {lu_table: 'wweia_cat', lu_code: '7006', lu_desc: 'Other fruit juice'},
      {lu_table: 'wweia_cat', lu_code: '7008', lu_desc: 'Vegetable juice'},
      {lu_table: 'wweia_cat', lu_code: '7102', lu_desc: 'Diet soft drinks'},
      {lu_table: 'wweia_cat', lu_code: '7104', lu_desc: 'Diet sport and energy drinks'},
      {lu_table: 'wweia_cat', lu_code: '7106', lu_desc: 'Other diet drinks'},
      {lu_table: 'wweia_cat', lu_code: '7202', lu_desc: 'Soft drinks'},
      {lu_table: 'wweia_cat', lu_code: '7204', lu_desc: 'Fruit drinks'},
      {lu_table: 'wweia_cat', lu_code: '7206', lu_desc: 'Sport and energy drinks'},
      {lu_table: 'wweia_cat', lu_code: '7208', lu_desc: 'Nutritional beverages'},
      {lu_table: 'wweia_cat', lu_code: '7220', lu_desc: 'Smoothies and grain drinks'},
      {lu_table: 'wweia_cat', lu_code: '7302', lu_desc: 'Coffee'},
      {lu_table: 'wweia_cat', lu_code: '7304', lu_desc: 'Tea'},
      {lu_table: 'wweia_cat', lu_code: '7502', lu_desc: 'Beer'},
      {lu_table: 'wweia_cat', lu_code: '7504', lu_desc: 'Wine'},
      {lu_table: 'wweia_cat', lu_code: '7506', lu_desc: 'Liquor and cocktails'},
      {lu_table: 'wweia_cat', lu_code: '7702', lu_desc: 'Tap water'},
      {lu_table: 'wweia_cat', lu_code: '7704', lu_desc: 'Bottled water'},
      {lu_table: 'wweia_cat', lu_code: '7802', lu_desc: 'Flavored or carbonated water'},
      {lu_table: 'wweia_cat', lu_code: '7804', lu_desc: 'Enhanced water'},
      {lu_table: 'wweia_cat', lu_code: '8002', lu_desc: 'Butter and animal fats'},
      {lu_table: 'wweia_cat', lu_code: '8004', lu_desc: 'Margarine'},
      {lu_table: 'wweia_cat', lu_code: '8006', lu_desc: 'Cream cheese, sour cream, whipped cream'},
      {lu_table: 'wweia_cat', lu_code: '8008', lu_desc: 'Cream and cream substitutes'},
      {lu_table: 'wweia_cat', lu_code: '8010', lu_desc: 'Mayonnaise'},
      {lu_table: 'wweia_cat', lu_code: '8012', lu_desc: 'Salad dressings and vegetable oils'},
      {lu_table: 'wweia_cat', lu_code: '8402', lu_desc: 'Tomato-based condiments'},
      {lu_table: 'wweia_cat', lu_code: '8404', lu_desc: 'Soy-based condiments'},
      {lu_table: 'wweia_cat', lu_code: '8406', lu_desc: 'Mustard and other condiments'},
      {lu_table: 'wweia_cat', lu_code: '8408', lu_desc: 'Olives, pickles, pickled vegetables'},
      {lu_table: 'wweia_cat', lu_code: '8410', lu_desc: 'Pasta sauces, tomato-based'},
      {lu_table: 'wweia_cat', lu_code: '8412', lu_desc: 'Dips, gravies, other sauces'},
      {lu_table: 'wweia_cat', lu_code: '8802', lu_desc: 'Sugars and honey'},
      {lu_table: 'wweia_cat', lu_code: '8804', lu_desc: 'Sugar substitutes'},
      {lu_table: 'wweia_cat', lu_code: '8806', lu_desc: 'Jams, syrups, toppings'},
      {lu_table: 'wweia_cat', lu_code: '9002', lu_desc: 'Baby food: cereals'},
      {lu_table: 'wweia_cat', lu_code: '9004', lu_desc: 'Baby food: fruit'},
      {lu_table: 'wweia_cat', lu_code: '9006', lu_desc: 'Baby food: vegetable'},
      {lu_table: 'wweia_cat', lu_code: '9008', lu_desc: 'Baby food: meat and dinners'},
      {lu_table: 'wweia_cat', lu_code: '9010', lu_desc: 'Baby food: yogurt'},
      {lu_table: 'wweia_cat', lu_code: '9012', lu_desc: 'Baby food: snacks and sweets'},
      {lu_table: 'wweia_cat', lu_code: '9202', lu_desc: 'Baby juice'},
      {lu_table: 'wweia_cat', lu_code: '9204', lu_desc: 'Baby water'},
      {lu_table: 'wweia_cat', lu_code: '9402', lu_desc: 'Formula, ready-to-feed'},
      {lu_table: 'wweia_cat', lu_code: '9404', lu_desc: 'Formula, prepared from powder'},
      {lu_table: 'wweia_cat', lu_code: '9406', lu_desc: 'Formula, prepared from concentrate'},
      {lu_table: 'wweia_cat', lu_code: '9602', lu_desc: 'Human milk'},
      {lu_table: 'wweia_cat', lu_code: '9802', lu_desc: 'Protein and nutritional powders'},
      {lu_table: 'wweia_cat', lu_code: '9999', lu_desc: 'Not included in a food category'},
      {lu_table: 'wweia_cat', lu_code: '9007', lu_desc: 'Baby food: mixtures'},
      {lu_table: 'wweia_cat', lu_code: '3740', lu_desc: 'Deli and cured meat sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3742', lu_desc: 'Meat and BBQ sandwiches'},
      {lu_table: 'wweia_cat', lu_code: '3744', lu_desc: 'Vegetable sandwiches/burgers'},
    ]
    #  lu_hash
    return lu_hash
  end
end