require 'spec_helper'
describe Jobs::GenerateExportCSVJob do
  it "should generate a csv file and update the export" do
    Sidekiq::Worker.clear_all
    organisation = Factory :organisation
    user = Factory(:user, organisation: organisation)
    petition = Factory(:petition, organisation: organisation)
    signature = Factory(:signature, petition: petition)
    csv_report = Factory :csv_report, exported_by: user, name: "my_file.csv"

    csv_report.export = Queries::Exports::PetitionSignaturesExport.new(organisation: organisation, petition_id: petition.id)
    csv_report.save!
    Jobs::GenerateExportCSVJob.perform_async(csv_report.id)
    Sidekiq::Worker.jobs.count.should == 1
    Sidekiq::Worker.drain_all
    csv_report.report.should_not be_nil
  end
end