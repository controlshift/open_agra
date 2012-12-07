class BlueStateDigitalConstituentWorker
  include Sidekiq::Worker

  def perform(constituent_id, cons_group_ids, api_parameters)
    api_parameters.symbolize_keys!
    threads = []

    cons_group_ids.each do |group_id|
      threads << Thread.new(group_id, constituent_id) do | gp_id, cons_id |
        beginning_time = Time.now
        thread_connection = BlueStateDigital::Connection.new(api_parameters)
        thread_connection.constituent_groups.add_cons_ids_to_group(gp_id, cons_id, wait_for_result: false)
        end_time = Time.now
        Rails.logger.debug "Constituent #{constituent_id} added to group #{gp_id} in #{(end_time - beginning_time)} seconds."
      end
    end

    threads.each {|t| t.join()}
  end
end