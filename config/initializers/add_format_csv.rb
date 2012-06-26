ActionController::Renderers.add :csv do |csv, options|
  data = csv.respond_to?(:to_csv) ? csv.to_csv(options[:fields]) : csv
  filename = options.key?(:filename) ? options[:filename] : "export"
  
  send_data data, :type => Mime::CSV, :disposition => "attachment; filename=#{filename}.csv"
end