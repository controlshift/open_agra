# Moonshine::Postgis

## ATTENTION FUTURE MOONSHINE POSTGIS MAINTAINER!

Welcome to you who has generated this Moonshine::Postgis plugin.

Here's what you have:

 * README.markdown: this file
 * LICENSE: the MIT license
 * lib/moonshine/postgis.rb: where the plugin code actually lives
 * moonshine/init.rb: required glue to let moonshine know about this plugin
 * spec/moonshine/postgis_spec.rb: example specs
 * spec/spec_helper.rb: helper for specs

This README is all just an example, but it should give you a This should be enough to get you started, but just wanted to give you a templated to get started documenting and developing.

This file should focus on:

 * explanation of what it's all about
 * a quick start guide
 * configuration options

The rest of this file is filled with idyllic and fictional information. Remember to review everything here, fix links, remove junk, etc.

PS: You might want to delete this section :)

## Introduction

Welcome to Moonshine::Postgis, a [Moonshine](http://github.com/railsmachine/moonshine) plugin for installing and managing [postgis](http://www.google.com/search?q=postgis)

Here's some quick links:

 * [Homepage](http://github.com/ACCOUNT/moonshine_postgis)
 * [Issues](http://github.com/ACCOUNT/moonshine_postgis/issues) 
 * [Wiki](http://github.com/ACCOUNT/moonshine_postgis/wiki) 
 * [Mailing List](http://groups.google.com)
 * Resources for using Postgis:
   * [Postgis Homepage](http://www.google.com/search?q=postgis)

## Quick Start

Moonshine::Postgis is installed as a Rails plugin:

    # Rails 2.x.x
    script/plugin install git://github.com/ACCOUNT/moonshine_postgis.git
    # Rails 3.x.x
    script/rails plugin install git://github.com/ACCOUNT/moonshine_postgis.git

Once it's installed, you can include it in your manifest:

    # app/manifests/application_manifest.rb
    class ApplicationManifest < Moonshine::Manifest:Rails

       # other recipes and configuration omitted

       # tell ApplicationManifest to use the postgis recipe
       recipe :postgis
    end

Ideally, things should work out of the box. If not, be sure to make the code detects missing configuration and fails with instructions. Also, include details about any required settings here.

## Configuration Options

Here's some other postgis configuration options you may be interested in.

 * `:degrees`: an integer representing the degree of postgis

These are namespaced under `:postgis`. They can be configured a few ways:

    # in global config/moonshine.yml
    :postgis:
      :degrees: 10000

    # in stage-specific moonshine.yml,
    # config/moonshine/staging.yml and config/moonshine/production.yml
    :postgis:
      :degrees: 10000

    # `configure` call in app/manifests/application_manifest.rb
    configure :postgis => { :degrees => 10000 }
