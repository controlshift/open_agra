module Jobs
  class UpdateConstituentJob
    include Sidekiq::Worker

    def perform(klass_id, klass, api_parameters)
      api_parameters = api_parameters.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      user_details = Kernel.const_get(klass).find klass_id

      info = {id: user_details.external_constituent_id, connection: BlueStateDigital::Connection.new(api_parameters) }
      info = info.merge({phones: [{phone: user_details.phone_number, phone_type: 'unknown'}]}) if user_details.phone_number.present?
      info = info.merge({addresses: [{ country: user_details.country, zip: user_details.postcode, is_primary: 1}]}) if user_details.postcode.present?


      cons = BlueStateDigital::Constituent.new(info)
      cons.save
      raise "Problem updating #{user_details.external_constituent_id} != #{cons.id}" if cons.id != user_details.external_constituent_id
      raise "Should not have created a new object for #{user_details.external_constituent_id}" if cons.is_new?
    end
  end
end