# **[ Sample ]** Export Report by Running Rake

## Description
This is sample repository to export report by rake in rails. 🙌

Using ruby gem [Devise](https://github.com/plataformatec/devise) to build Member feature and then adding USERs data to run rake.

Final goal is getting export CSV File after running rake command line! 😎

## Version
- **Ruby** 2.6.0
- **Rails** 5.2.4
- **postgreSQL** 1.1.4

## Getting Start
- `$ git clone https://github.com/chaochaowu/export_report_by_running_rake.git`
- `$ cd export_report_by_running_rake`
- `$ bundle install`
- `$ bundle exec rails db:create`
- `$ bundle exec rails db:migrate`
- **[ option ]** `$ bundle exec rails db:seed` would create at least 20 USERs in your database that you don' t need to create USERs by yourself.
- `$ bundle exec rails server`
- Let' s sign up USERs which you need to run rake! 👭👫👬💻

## Modifying Registration DateTime
- `$ bundle exec rails c`
- `> user = User.find_by(id: USER_ID)`
- `> user.update(created_at: DATE_TIME_YOU_WANT_TO_CHANGE)  # => true`

## Checking Data via postgreSQL
This repository use postgreSQL as database. If you haven' t setup postgreSQL in your computer yet, you can follow [postgreSQL wiki](https://wiki.postgresql.org/wiki/Homebrew) to install via Homebrew.

- `$ psql` to into postgreSQL.
- `$ \l` let you view what database you have created.
- `$ \c export_report_by_running_rake_sample/dev` to enter development database of this repository.
- `$ select * from users;` to view user data.
