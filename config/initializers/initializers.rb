load 'lib/liquid/filters.rb'
load 'lib/liquid/tags.rb'

SeedFu.quiet = true

FacebookShareWidget.access_token_session_key = :facebook_access_token

Tabletastic.default_table_html = {'class' => 'table table-striped'}

require "sunspot/rails/solr_logging" if Rails.env.development?
Sunspot.session = Sunspot::SessionProxy::SilentFailSessionProxy.new(Sunspot.session)

$liquid_cache_store = ActiveSupport::Cache::MemoryStore.new size: 250.kilobytes

if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end