# Welome to Agra
## Wiki

Another place to find more information is the [agra wiki](https://github.com/controlshift/agra/wiki).

## Setup

External packages required for development:

rvm - the current ruby version for the app is defined in a .rvmrc file.
postgres - current heroku production version (brew install postgresql). 
git

CI Server:
http://ci.controlshiftlabs.com:8080/

UAT Server:
manually pushed, for QA and presentation to external entities
push a tagged good build using rake heroku:deploy
http://agra-uat.herokuapp.com/

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

ENVIRONMENT VARIABLES

- ENV['SENDGRID_USERNAME'] : needed by Heroku to set up the sendgrid add-on
- ENV['SENDGRID_PASSWORD'] :needed by Heroku to set up the sendgrid add-on

HEROKU PLUGINS
Fix environment variables during rake taks (connection refused error)
http://devcenter.heroku.com/articles/labs-user-env-compile

DOMAIN SET UP FOR HEROKU
heroku addons:add custom_domains --app APPNAME
heroku domains:add mynewclientdomain.com --app APPNAME

## Deployment & Operations


### Redis

#### Failover

Redis is setup as a master/slave pair, so it should be possible to failover in the event of a failure in the master. Steps below:

* if redis1 is up, on redis1:
  * stop redis if it hasn't been: sudo /etc/init.d/redis-server stop
  * 
* on redis2:
  * check `redis-cli info | grep master` for master information
  * make note of last io to determine how far behind it is
  * start `redis-cli` as an interactive prompt:
    * info
    * slaveof no one
    * info
* in a copy of the repository:
  * update .env.<stage>'s REDIS_URL to use redis2's internal IP (ie 10.0.x.x)
  * update config/moonshine/<stage>.yml's :redis_master_slave_pairs: to use the one marked failover
  * if redis1 is down, comment out redis1 in config/deploy/<stage>.rb
  * commit & push changes
  * cap <stage> deploy
* on redis2:
  * confirm role: `redis-cli info | grep role`
* confirm application availability

#### Fail back

After fail over is done, there's not really a reason to make redis1 the master again unless you need to work on redis2. The steps to make redis1 master again are similar to above:

* on redis1:
  * based on the steps above, make sure you have deployed to redis2:
    * uncomment redis1 in config/deploy/<stage>.rb
    * cap <stage> deploy
  * start redis if it's not running: sudo /etc/init.d/redis-server start
  * from redis-cli prompt:
    * check `info`, should be slave of redis2 still
    * confirm that master_link is up, that master_sync_in_progress is 0 (not running)
* on redis2:
  * stop redis: sudo /etc/init.d/redis-server start
* on redis1:
  * start redis-cli:
     * slaveof no one
* in a copy of the repository:
  * update .env.<stage>'s REDIS_URL to use redis1's internal IP (ie 10.0.x.x)
  * update config/moonshine/<stage>.yml's `:redis_master_slave_pairs:` to use the one _not_ marked failover
  * commit & push changes
  * cap <stage> deploy

### Postgresql

Most of postgresql's configuration is automated with moonshine. There are some nuances that need manual setup still.


#### Setting up a new replication pair

* Update stage specific files:
 * config/moonshine/<stage>.yml:
  * Add servers to `:database_servers`
  * Add pair to `:database_primary_standby_pairs`
 * config/deploy/<stage>.rb:
  * For primary: `server 'hostname', :db, :primary => true`
  * For standby: `server 'hostname', :db, :standby => true`
* deploy:setup
  * comment out other servers to avoid interrupting their service in config/deploy/<stage>.rb
  * cap <stage> deploy:setup
* initial deploy
 * comment out other servers to avoid interrupting their service in config/deploy/<stage>.rb (ie leave them uncommented
 * cap <stage> moonshine rm deploy
 * there will likely be failures. in particular, postgresql won't start on standby, because it's configured to be a standby, and wouldn't have access to primary yet
 * manually update sudoers file (gross):
  * ssh to each
  * sudo visudo
  * `%admin  ALL=NOPASSWD:   ALL` becomes `%admin  ALL=(ALL) NOPASSWD:   ALL`
  * this is so rails user can sudo to postgres for the next steps
* add postgres public keys
 * cap <stage> postgresql:replication:public\_keys
 * copy into config/moonshine/<stage>.yml's :postgresql -> :public\_ssh\_keys:
 * cap <stage> moonshine rm deploy
 * there will still be some errors until we build stanby's replication
  * format is fqdn: key
* make sure servers can ssh without any prompting:
 * sudo su - postgres
 *  ssh to other host's private IP, accept host key if necessary
* rebuild database as utf8:
 * nonobvious, but removing and reinstalling is the simplest way
 * replace 9.1 with correct version
 * sudo su -
  * apt-get purge -y postgresql-9.1 postgresql-client-9.1 postgresql-client-common postgresql-common postgresql-server-dev-9.1
  * apt-get install postgresql-9.1
 * sudo su - postgres
  * psql -l
  * should see 'UTF8' for everything
* if this is 9.2, it no longer generates a server.crt by default, so we'll need to make one.
 * refer to http://www.postgresql.org/docs/9.2/static/ssl-tcp.html
  * sudo su - postgres
  * cd 9.2/main
  * openssl req -new -text -out server.req
   * enter anything > 4 characters for password, we'll remove in a second
   * enter defaults except for Common Name, enter localhost
  * openssl rsa -in privkey.pem -out server.key
   * use the same password above, after that it won't have a password
  * rm privkey.pem
  * openssl req -x509 -in server.req -text -key server.key -out server.crt
  * chmod og-rwx server.key
 * follow steps at the bottom for creating a key
* deploy one last time to update the newly reinstalled version of postgresql with the moonshined config
 * cap <stage> moonshine rm deploy
* and manually restart postgresql, because this does not happen automatically during deploys to avoid accidental restarts
* follow steps below for postgres replication setup
* uncomment previously commented out lines in config/deploy/<stage>.rb
* commit all the things

#### Postgres Replication

##### Setting Up / Restoring Replication

Before starting any of this, you will NEED  to COMMENT OUT any DB servers pairs you are not working on. Otherwise, it'll put in-use servers into backup mode, and also rebuild its replica from scratch.

Also, this will be incredibly slow for large databases, so proceed with care. Most common use should be to setup replication for new servers.

* Note, for postgresql 9.1 servers, you'll need to append to append this to cap task:
 * -S postgresql_version=9.1
* Ensure that WAL archiving is enabled and working:
 * cap <stage>  postgresql:replication:setup:wal_archiving_status
 * look for 'archive mode' being 'on'
 * look for a process named like `postgres: wal writer process`
* Create a base backup (on master):
 * `cap <stage> postgresql:replication:setup:take_snapshot_from_primary`
 * this will probably hang with a message like
  * `HINT:  Check that your archive_command is executing properly.  pg_stop_backup can be cancelled safely, but the database backup will not be usable without all the WAL segments.`
  * as it says, you can kill capistrano at this point
 * TODO further automate: don't try to start backup if already backing up. parse output to determine when the HINT is displayed, and exit at that point
* Copy backup from primary to replica:
 * `cap <stage> postgresql:replication:setup:copy_snapshot_from_primary_to_standby`
 * this does copy the snapshot to the host it's running on. that could be a big problem if the database is sufficiently large
* Decompress backup (on slave) and start the database
 * `cap <stage> postgresql:replication:setup:apply_snapshot_to_standby`
* Check replication status
 * `cap <stage> postgresql:replication:status`

#### Failover

* if db1 is running:
** cap <stage> postgresql:replication:status
* in a copy of the repository:
** cap <stage> postgresql:standby:bringup
*** IMPORTANT! This needs to happen before you update the <stage>.yml before, or it'd be run on the wrong host
** update config/moonshine/<stage>.yml to update `:database_primary_standby_pairs` to use the failover pair (IMPORTANT
** update .env.<stage>'s POSTGRESQL_HOST=10.0.2.94 to use db2's internal IP (10.0.x.x)
** if db1 is down completely (unsshable), comment out in config/deploy/<stage>.rb
** update config/deploy/<stage>.rb to switch primary & standby options for dbs
** cap <stage> deploy
* confirm application still up
* follow the steps in `replication` to re-establish db1 as a standby of db2

#### Failback

* same instructions as above, but swap db1 and db2

