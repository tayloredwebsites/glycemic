# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version
- System dependencies
    - Rails 7
    - PostgreSQL
- Configuration
- PostgreSQL Database commands
    - log in using postgres user

        sudo -i -u postgres
    - list databases

          \l
          glycemic_development | dave     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
          glycemic_test        | dave     | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
    - create admin user dave

          createuser -s -r dave
- Database initialization in Rails

      bin/rails db:create
      Created database 'glycemic_development'
      Created database 'glycemic_test'
- Database Backups & Restores (
    - stored in (rails root)/db/backups/
    - database backups

          pg_dump --username dave --password --dbname glycemic_development --format=custom --file db/backups/2023-01-22d-initial2users.sql
    - database restores

          pg_restore --verbose --clean --no-acl --no-owner --dbname glycemic_development db/backups/2023-01-22d-initial2users.sql
- [Jira board](https://tayloredwebsites.atlassian.net/jira/software/projects/GLYC/boards/1)
- [Database Diagram](https://lucid.app/lucidchart/7013dcfa-d88b-42d7-b0b0-84bd45907e7c/edit)
- How to run the test suite
- Services (job queues, cache servers, search engines, etc.)
- Deployment instructions
- ...

[Markdown Syntax](https://www.markdownguide.org/basic-syntax)
