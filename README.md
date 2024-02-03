# README

## Diet Support Program

### Purpose and Goals

The program is being designed to help you plan your diet, and to give you feedback to better help you meet your nutritional related objectives.:
- Objectives you might want to monitor:
    - calorie intake -for its possible impact on weight.
    - carbohydrate to protein ratio - for its probable impact on blood sugar.
    - glycemic load - for its probable impact on blood sugar.
    - PRAL index - for its probable impact of food on body acid balance and kidneys.
   -  anti-nutrients such as oxalates for their possible impact on kidney stones.
    - calcium and other mineral intake with possible impact on bone health, etc
    - more...
- USDA Nutritional Data will be preloaded into the program.
    - Thee nutritional information of many foods will be available from the USDA nutritional databases.
    - The USDA additionally has many pre-packaged foods and meals that can be easily obtained by this program.
- Home cooked foods and Recipes:
    - Foods that you prepare will also be able to be stored in the program, and the program will conveniently let you determine the nutritional benefits of your recipes and meals from them.
    - Wnen you enter your home cooded foods, it will be able to be entered as a recipe.  Since the recipe has the ingredient quantities, this will provide both printable instructions, as well as ingredient quantities needed to determine nutritional values of the food prepared.
    - There will be convenient ways to provide for substitutions and enhancements to your recipes.
- Meals
    - Meals will consist of food portions of  any known USDA foods, as well as  your home cooked foods.
    - By adusting portions and foods, a meal may be planned and adjusted until it meets your goals.
-  Meeting your Goals:
    - You will be able to develop your own goal ranges of ideal (green) range, as well as warning (yellow) and alert(red) ranges .
    - Since all of these ranges will be displayed simultaneously, his will make it easy to easily monitor  all of your goals at the same time.
    - The goals will be available on the foods and meals pages
- Daily results:
    - the plan will be for you to be ability to enter your daily meals, so that you will be able to see how you met your goals in a daily summary page.
    - The plan will be to also allow you to enter test results, such as blood sugar levels, to help monitor and analyze the impact on your diet.
    - Eventually, it it hoped that we will be able to provide statistical analysis of your diet and test results.

### Development Plan

DONE
- Ability to enter foods, nutrients, and the nutrients in a food.

NEXT STEPS
- Download the foods and nutrients in the USDA database, and populate the database with them.
- Foods listing page with various sorts and filters to help choose foods for a meal.
- Dynamically develop a meal with portions of foods, with the ability to adjust portions till goals are met.
- Save a meal for future reference.
- Meal listing page with various sorts and filters to help choose a meal.
- Home cooked foods & Recipes listing page, with various sorts and filters to help choose one.
    - Screen viewable and printable recipes, with the nutritional information by total and portion size(s).
    - Create variations of a recipe using alternate ingredients (e.g. whole wheat vs all purpose flour) or quantities.
    - When viewing a Home Cooked food, the recipe will be displayed with a list of existing saved variations.
    - ability to write up notes on the impact of a recipe variation.
- Ability to enter all meals for the day, to obtain a daily summary page
- Ability to enter tests, so statistical analysis of your diet on your tests could be done

### Testing

- This diet_support program has been developed with concurrent automated testing (test driven and/or tested as developed).  This helps ensure that the software will have minimal bugs.
- TODO - set up Github CI, to ensure that all pull requests have a clean automated test run before merging into the code base.

### Copyright

This software and derivations of it are to be free to use.  It may be modified only if the changes are publicly available and free under the [AGPL-3.0-only](https://opensource.org/license/agpl-v3/) license.

(C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)

Licensed under  [AGPL-3.0-only](https://opensource.org/license/agpl-v3/).


### System Dependencies

- Rails 7
- PostgreSQL 12
- ruby 3.1

### Developer Installation Instructions

#### Linux (Mint 20.3)

- TODO Instructions to install postgres12
- TODO Instructions to install rbenv
- TODO Instructions to install ruby 3.1.3
- TODO Instructions to install bundler
- TODO Instructions to install rails 7.0.4
- TODO Instructions to configure rails

#### Upload Nutrition Data

Run the following rake tasks to load up the database tables from the .csv files from the USDA

1. If necessary create or reset the development and test databases:
        bin/rails db:reset

1. load up the two category lookup tables and the nutrients table

      bin/rails import_usda_csv_files:perform[1]

1. run the fixes for duplicate nutrients

      bin/rails import_usda_csv_files:perform[2]

1.  load the ff_foods.csv into the usda_foods table

      bin/rails import_usda_csv_files:perform[3]

1. load the ff_food_nutrients.csv into the usda_food_nutrients table

      bin/rails import_usda_csv_files:perform[4]

1. load the Food and FoodNutrients table from the UsdaFood and UsdaFoodNutrient tables

      bin/rails import_usda_csv_files:perform[5]

### Tips and Hints

#### Markdown

- [Markdown Syntax](https://www.markdownguide.org/basic-syntax)

#### PostgreSQL

- PostgreSQL Database commands
    - log in using postgres user

          sudo -i -u postgres

    - bring up psql

          psql
    	      
    - list databases

          \l
        - glycemic_development | {mydbusername}     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
        - glycemic_test        | {mydbusername}     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 
    - create admin user <mydbusername>

          createuser -s -r {mydbusername}

#### Database Backups & Restores

- determine and create if necessary your directory archiving backups folder
	- this will be referred to as {backupFolder} 
- locate the postgres database files directory (can be accessed by root or postgres user)

        sudo -iu postgres
        psql
        show data_directory;

	- /var/lib/postgresql/12/main

- create a postgres owned backup folder under the postgresql folder.

        sudo -iu postgres
        mkdir -p {pgBackupsFolder}
        
	- e.g.: /var/lib/postgresql/dbbackups/diet/
	
- database backups (compressed to postgres data folder as postgres user).

        sudo -iu postgres
        pg_dump --format=tar --dbname=glycemic_development | gzip > {pgBackupsFolder}/{yyyy-mm-ddn-desc}.tar.gz
        exit

- save database backups to cloud or other safe location
        sudo cp {pgBackupsFolder}/{yyyy-mm-ddn-desc}.tar.gz {backup_folder}
        sudo chown {username}:{username} {backup_folder}/*
        ls -al {backup_folder}

- database restores
	- be sure to shut down all web servers and rails consoles

          sudo -iu postgres
          gunzip < {pgBackupsFolder}/{yyyy-mm-ddn-desc}.tar.gz | pg_restore --clean --dbname=glycemic_development

- Notes on backups and restores:
    - if you need to restore a database backup that is not gzipped, then use restore command without the gunzip (everything after the | )
    - if you need to restore from your safe backup location, I recommend copying the backup to the {pgBackupsFolder} to avoid authorization issues.

#### Database Diagram

- Database diagram - is located in the site's public directory, which is generated using [Mermaid.js](https://mermaid.js.org/)

- Database initialization/rebuild in Rails

      bin/rails db:reset
      Created database 'glycemic_development'
      Created database 'glycemic_test'


#### Jira

- Team members will be given access to the [Jira board](https://tayloredwebsites.atlassian.net/jira/software/projects/GLYC/boards/1)
