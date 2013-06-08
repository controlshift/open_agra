Moonshine Multi Server
-----------------------

A plugin for [Moonshine](http://github.com/railsmachine/moonshine)
===================================================================

A plugin for deploying one application to multiple servers

Instructions
=============

* Install the [Moonshine](http://github.com/railsmachine/moonshine)
* Configure servers for capistrano setting the appropriate role(s).  Here is an example `config/deploy.rb`:

<pre>
  server 'web.example.com', :web, :primary => true
  server 'app.example.com', :app, :primary => true
  server 'db.example.com', :db, :primary => true
</pre>

* Install the Moonshine Multi Server plugin:

<pre><code>Rails 2: script/plugin install https://github.com/railsmachine/moonshine_multi_server.git
Rails 3: script/rails plugin install https://github.com/railsmachine/moonshine_multi_server.git
</code></pre>

* After the plugin is installed, generate some manifests!

<pre>
Rails 2: script/generate moonshine:multi_server web app db
Rails 3: script/rails generate moonshine:multi_server web app db
</pre>

* create a manifest for each role:
  * `app/manifests/application_manifest_.rb`
  * `app/manifests/database_manifest_.rb`
  * `app/manifests/web_manifest_.rb`
* Add the stacks you need to each manifest.  Here is an example `app/manifests/application_manifest.rb`:
    
<pre><code>require "#{File.dirname(__FILE__)}/../../vendor/plugins/moonshine/lib/moonshine.rb"
class ApplicationManifest < Moonshine::Manifest::Rails
  include Moonshine::MultiServer
  recipe :standalone_application_stack
end</code></pre>

* Add one bit to your capistrano `config/deploy.rb`

<pre><code>namespace :moonshine do
  task :apply do
    moonshine.multi_server_apply
  end  
end</code></pre>

TODO
====

* Document MySQL allowed hosts
* Document `*_servers` helpers
* More thorough examples
* Examples with having more than app,web,db roles
* Generator?!
 * <code>script/generate moonshine_multi_server app web db</code> util
* build capistrano servers from `*_servers` datas
