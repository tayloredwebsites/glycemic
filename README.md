# README

## Diet Support Program

### Purpose and Goals
- 

#### Testing
- This diet_support program has been developed with concurrent automated testing (test driven and/or tested as developed).  This helps ensure that the software will have mimimal bugs.
- TODO - set up Github CI, to ensure that all pull requests have a clean automated test run before merging into the code base.

### Copyright

This software and derivations of it are to be free to use.  It may be modified only if the changes are publicly available and free under the AGPL-3.0-only license.

(C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)

Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/


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
- TODO Instructions toinstall rails 7.0.4
- TODO Instructions toconfigure rails

### Tips and Hints

#### Markdown
- [Markdown Syntax](https://www.markdownguide.org/basic-syntax)

#### PostgreSQL
- PostgreSQL Database commands
    - log in using postgres user

        sudo -i -u postgres
    - list databases

          \l
          glycemic_development | dave     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
          glycemic_test        | dave     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    - create admin user dave

          createuser -s -r dave
- Database Backups & Restores (
    - stored in (rails root)/db/backups/
    - database backups

          pg_dump --username dave --password --dbname glycemic_development --format=custom --file db/backups/2023-01-22d-initial2users.sql
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
