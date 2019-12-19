# README

## Description
This is sample repository to export report with rake in rails. 🙌

## Version
- **Ruby** 2.6.0
- **Rails** 5.2.4
- **postgreSQL** 1.1.4

## Getting Start
- `$ git clone https://github.com/chaochaowu/export_report_with_rake.git`
- `$ cd export_report_with_rake`
- `$ bundle install`
- `$ bundle exec rails db:create`
- `$ bundle exec rails db:migrate`
- `$ bundle exec rails server`
- Let' s sign up USERs which you need to run rake! 👭👫👬💻

## Checking Data with postgreSQL
- `$ psql` to into postgreSQL.
- `$ \l` let you view what database you have created.
- `$ \c export_report_with_rake_sample/dev` to enter development database of this repository.
- `$ select * from users;` to view user data.

## Modifying Registration DateTime
- `$ bundle exec rails c`
- `> user = User.find_by(id: USER_ID)`
- `> user.update(created_at: DATE_TIME_YOU_WANT_TO_CHANGE)  # => true`