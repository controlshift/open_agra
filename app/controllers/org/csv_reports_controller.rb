class Org::CsvReportsController < ApplicationController
  before_filter :load_report

  def show
    if @report.report.options[:storage] == :filesystem
      redirect_to @report.report.url
    else
      redirect_to @report.report.expiring_url(10)
    end
  end

  private

  def load_report
    @report = CsvReport.find params[:id]
    raise ActiveRecord::RecordNotFound if @report.exported_by != current_user
  end
end