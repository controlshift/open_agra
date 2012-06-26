load 'lib/liquid/filters.rb'
load 'lib/liquid/tags.rb'

SeedFu.quiet = true

#keep failed jobs for retry
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
#http://stackoverflow.com/questions/5972903/how-to-make-exceptionnotifier-work-with-delayed-job-in-rails-3
Delayed::Worker.class_eval do
  def handle_failed_job_with_notification(job, error)
    handle_failed_job_without_notification(job, error)
    
    # only actually send mail in production
    if Rails.env.production?
      # rescue if ExceptionNotifier fails for some reason
      begin
        ExceptionNotifier::Notifier.background_exception_notification(error)
      rescue Exception => e
        Rails.logger.error "ExceptionNotifier failed: #{e.class.name}: #{e.message}"
        e.backtrace.each do |f|
          Rails.logger.error "  #{f}"
        end
        Rails.logger.flush
      end
    end
  end 
  alias_method_chain :handle_failed_job, :notification 
end

Tabletastic.default_table_html = {'class' => 'table table-striped'}

require "sunspot/rails/solr_logging" if Rails.env.development?
Sunspot.session = Sunspot::SessionProxy::SilentFailSessionProxy.new(Sunspot.session)

$liquid_cache_store = ActiveSupport::Cache::MemoryStore.new size: 250.kilobytes

if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end