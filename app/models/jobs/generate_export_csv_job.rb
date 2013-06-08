require 'zip/zip'

module Jobs
  class GenerateExportCSVJob
    include Sidekiq::Worker
    
    def perform csv_report_id
      @csv_report = ::CsvReport.find(csv_report_id)
      generate_report
      GC.start
    end

    def generate_report
      file = HttpUploadFile.new(@csv_report.name, "text/csv")

      File.open(file.path, 'wb') do |f|
        @csv_report.export.as_csv_stream.each do | chunk|
          f.write chunk
        end
      end

      @csv_report.update_attribute(:report, file)
      ExportsMailer.send_generation_confirmation(@csv_report)
    end
  end
end
