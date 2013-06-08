* flag for mmm
  * installs mmm plugin
  * adds to haproxy manifest
  * adds to database manifest
  * configuration builders
  * adds iptable rules for mmm agent to database
  * adds read-only=1 to configuration
  * adds mysql configuration for haproxy manifest

* flag for database
  * mysql:
    * installs mysql_tools plugin
    * adds bind-address = 0.0.0.0
  * postgresql
    * installs postgres_9 plugin
* detect asset pipeline
  * install nodejs
