require 'spec_helper'

describe "petitions/view/_show_signatures_or_not.html.haml" do
  let(:petition) { Factory(:petition) }
  
  it "should display signatures if equal or more than 5 signatures" do
    petition.stub(:cached_signatures_size) { 5 }
    petition.stub(:recent_signatures) { mock }
    stub_template "/petitions/view/petition_signature" => "signatures"
    assign :petition, petition 

    render

    rendered.should =~ /signatures/

  end

  it "should not display signatures if less than 5 signatures" do
    stub_template "/petitions/view/petition_signature" => "signatures"
    assign :petition, petition 

    render

    rendered.should_not =~ /signatures/

  end


end

