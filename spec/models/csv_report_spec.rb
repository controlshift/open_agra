# == Schema Information
#
# Table name: csv_reports
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  exported_by_id      :integer
#  report_file_name    :string(255)
#  report_content_type :string(255)
#  report_file_size    :integer
#  report_updated_at   :datetime
#  query_options       :hstore
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#

require 'spec_helper'

describe CsvReport do

  it { should validate_presence_of(:exported_by) }
  it { should validate_presence_of(:name) }
  it { should belong_to(:exported_by) }

  it "should be able to save options for the query" do
    csv_report = Factory :csv_report, :exported_by => Factory(:user)
    csv_report.query_options = {'class' => 'this is a test'}
    csv_report.save!.should_not be_nil
    csv_report.reload.query_options.should == {'class' => 'this is a test'}
  end

  it "should be able to get query object from stored csv_report" do
    organisation = Factory(:organisation)
    group = Factory(:group)
    csv_report = Factory :csv_report, :exported_by => Factory(:user), :query_options => {'class_name' => 'Queries::Exports::MembersForGroupExport', 'organisation_id' => organisation.id, 'group_id' => group.id}
    csv_report.export.should_not be_nil
    csv_report.export.organisation.id.should == organisation.id
    Group.find(csv_report.export.group_id).id == group.id
  end

  it "should be able to store query object as attributes in report object" do
    organisation = Factory :organisation
    group = Factory(:group)
    export = Queries::Exports::MembersForGroupExport.new(organisation: organisation, group_id: group.id)
    csv_report = CsvReport.new :exported_by => Factory(:user), :export => export, :name => 'test-report'
    csv_report.query_options.should == {'class_name' => 'Queries::Exports::MembersForGroupExport', 'organisation_id' => organisation.id, 'group_id' => group.id}
  end
end
