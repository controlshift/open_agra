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

class CsvReport < ActiveRecord::Base
  include HasPaperclipFile
  attr_accessible :exported_by, :name, :export

  scope :displayable, order('updated_at desc')
  serialize :query_options, ActiveRecord::Coders::Hstore
  validates :name, presence: true
  validates :exported_by, presence: true
  belongs_to :exported_by, :class_name => 'User'

  has_paperclip_file :report, :attr_accessible => true, :paperclip_options => {:s3_permissions => :private, :s3_protocol => 'http', :cache_control => 'private'}

  def export
    self.query_options['class_name'].constantize.new(self.query_options.
      merge(organisation: Organisation.find(self.query_options['organisation_id'])))
  end

  def export= query
    values = query.instance_values
    values.merge!('class_name' => query.class.to_s, 'organisation_id' => values.delete('organisation').id)
    self.query_options = values
  end

end
