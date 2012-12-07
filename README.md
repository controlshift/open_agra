# Open Agra

Open Agra is the open source version of the ControlShift Labs tools. We reserve the latest features for paid subscribers, and
release our code-base as open-source every 3-6 months.

## Setup

External packages required for development:

rvm - the current ruby version for the app is defined in a .rvmrc file.
postgres - current heroku production version (brew install postgresql).
redis
git


To start development from a machine with rvm and postgres installed:

git clone git@github.com:controlshift/agra.git
cd agra
gem install bundler
bundle install
rake db:create
rake db:migrate
rails s

Notable bits and pieces in use:

frontend technologies:
- twitter bootstrap css
- simple_form
- tabletastic
- haml 
- coffeescript

testing:
- rspec
- capybara for acceptance testing

NATIVE DEPENDENCIES

Solr
Qt WebKit - https://github.com/thoughtbot/capybara-webkit/wiki/Installing-QT

