# Hob, the awesome deployer

## Example configuration of application

### Prepare commands
* cp /config/database.yml.example config/database.yml
* bundle install
* bundle exec rake db:migrate
* bundle exec rake db:migrate RAILS_ENV=test

### Test commands
* bundle exec rspec

### Start commands
* bundle exec thin -p 8082 -d start

### Stop commands
* if [-f $APP_CURRENT_DIR/tmp/pids/thin.pid]; then kill `cat $APP_CURRENT_DIR/tmp/pids/thin.pid`; fi
