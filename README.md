# Open Agra

## Setup

External packages required for development:

rvm - the current ruby version for the app is defined in a .rvmrc file.
postgres - current heroku production version (brew install postgresql). 
git


To start development from a machine with rvm and postgres installed:

git clone git@github.com:controlshift/open_agra.git
cd agra
gem install bundler
bundle install
rake db:create
rake db:migrate
rake db:prepare_organisation
rake db:seed_fu

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

