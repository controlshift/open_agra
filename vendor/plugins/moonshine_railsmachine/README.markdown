# Moonshine::Railsmachine

## Introduction

Welcome to Moonshine::Railsmachine, a [Moonshine](http://github.com/railsmachine/moonshine) plugin for setting some defaults for an application hosted with Rails Machine.

Here's some quick links:

 * [Homepage](http://github.com/railsmachine/moonshine_railsmachine)
 * [Issues](http://github.com/railsmachine/moonshine_railsmachine/issues) 
 * [Wiki](http://github.comrailsmachineACCOUNT/moonshine_railsmachine/wiki) 

## Quick Start

Moonshine::Railsmachine is installed as a Rails plugin:

    # Rails 2.x.x
    script/plugin install git://github.com/railsmachine/moonshine_railsmachine.git
    # Rails 3.x.x
    script/rails plugin install git://github.com/railsmachine/moonshine_railsmachine.git

Once it's installed, you can include it in your manifest:

    # app/manifests/application_manifest.rb
    class ApplicationManifest < Moonshine::Manifest:Rails
       include Moonshine::Railsmachine

       # other recipes and configuration omitted

       # tell ApplicationManifest to use the railsmachine recipe
       recipe :railsmachine
    end

Ideally, things should work out of the box. If not, be sure to make the code detects missing configuration and fails with instructions. Also, include details about any required settings here.

## What it does:

* Adds Rails Machine authorized ssh keys to ~/.ssh/authorized_keys for moonshine_ssh
* Adds Rails Machine whitelisted servers to /etc/hosts.allow for moonshine_denyhosts
* Adds Rails Machine's Scout public key  for using Rails Machine Scout plugins for moonshine_scout
* Defaults heartbeat interface to eth1 for moonshine_heartbeat
* Adds convert_public_ip_to_private method for use with moonshine_multi_server

## Configuration Options

None.
