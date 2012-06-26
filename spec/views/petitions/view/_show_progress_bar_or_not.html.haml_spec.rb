require 'spec_helper'

describe "petitions/view/_show_progress_bar_or_not.html.haml" do
  let(:petition) { Factory(:petition) }
  
  it "should display progress bar if number of signatures is equal or more than 50" do
    petition.stub(:cached_signatures_size) { 50 }
    stub_template "petitions/view/_petition_progress" => "progress bar"
    assign :petition, petition 

    render

    rendered.should =~ /progress bar/

  end

  it "should not display progress bar if number of signatures is less than 50" do
    stub_template "petitions/view/_petition_progress" => "progress bar"
    assign :petition, petition 

    render

    rendered.should_not =~ /progress bar/

  end


end

