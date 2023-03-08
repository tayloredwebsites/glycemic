# README

## Diet Support Program

### Purpose and Goals
- This website is intended to help wisely develop and manage a diet to help meet any of a number of possible goals.  These goals could include:
    - monitoring calorie intake.
    - monitoring carbohydrate to protein ratio - probable impact on blood sugar.
    - monitoring glycemic load - probable impact on blood sugar.
    - monitoring PRAL index (probable impact of food on body acid balance and kidneys).
   -  monitoring anti-nutrients such as oxalates with possible impact on kidney stones.
    - monitoring calcium intake with possible impact on kidney stones..
    -  more...
- The nutrition information of foods will be downloaded (as needed) using the USDA nutrition website APIs.
- Some pre-packaged meals are already available from the USDA, so the accurate nutrition of these meals will be easy to obtain.
- Home cooked meals will contain food portions from foods, or  your recipes.
    - the program will assist you in entering food portions so that the nutrition of that portion is available.
    - the program will automatically accumulate the nutrition of the portions you have chosen for a meal.
    - the nutritional content of an entire recipe will be stored so the nutrition of a portion of a recipe will be known.
-  By adusting portions and foods, a meal may be developed and adjusted until you meet your goals.
-  Goals will be made up of an ideal (green) range, a maximum and/or minimum to provide upper and lower red ranges, and yellow ranges between.  This will make it easy to easily monitor  multiple goals at the same time.

### Development Plan
DONE
- Ability to enter foods, nutrients, and the nutrients in a food.

NEXT STEPS
- Download the foods and nutrients in the USDA database, and populate the database with them.
- Foods listing page with various sorts and filters to help choose foods for a meal.
- Ability to download the nutritional values of a food from the USDA website if not done already.
- Dynamically develop a meal with portions of foods, with the ability to adjust portions till goals are met.
- Save a meal for future reference.
- Meal listing page with various sorts and filters to help choose a meal.
- Recipes listing page, with various sorts and filters to help choose a recipe.
    - Various adjustments to recipes will allow for comparing the nutrition of the dishes, to better meet goals.
    - Recipes will be designed to assist in having accurate recipe and portion nutrition.

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

#### Linux (Mint 20.3 Cinnamon 5.2.7 )
- TODO Instructions to install postgres12
- TODO Instructions to install rbenv
- TODO Instructions to install ruby 3.1.3
- TODO Instructions to install bundler
- TODO Instructions to install rails 7.0.4
- TODO Instructions to configure rails

### Tips and Hints

#### Markdown
- [Markdown Syntax](https://www.markdownguide.org/basic-syntax)

#### PostgreSQL
- PostgreSQL Database commands
    - log in using postgres user

        sudo -i -u postgres
    - list databases

          \l
          glycemic_development | <mydbusername>     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
          glycemic_test        | <mydbusername>     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    - create admin user <mydbusername>

          createuser -s -r <mydbusername>
- Database Backups & Restores (
    - stored in (rails root)/db/backups/
    - database backups

          pg_dump --username <mydbusername> --password --dbname glycemic_development --format=custom --file db/backups/2023-01-22d-initial2users.sql
    - database restores

          pg_restore --verbose --clean --no-acl --no-owner --dbname glycemic_development db/backups/2023-01-22d-initial2users.sql

#### Database
- Database diagram - is located in the site's public directory, which is generated using [Mermaid.js](https://mermaid.js.org/)
- Database initialization in Rails

      bin/rails db:create
      Created database 'glycemic_development'
      Created database 'glycemic_test'
      
#### Jira
- Team members will be given access to the [Jira board](https://tayloredwebsites.atlassian.net/jira/software/projects/GLYC/boards/1)
