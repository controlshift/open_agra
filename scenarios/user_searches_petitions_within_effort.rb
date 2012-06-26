require File.dirname(__FILE__) + '/scenario_helper.rb'

include LoginHelper
include PetitionHelper

describe 'User searches petition within effort', type: :request, nip: true do
  before :each do
    @effort = Factory(:effort, organisation: @current_organisation, ask_for_location: true)
    user = Factory(:user, organisation: @current_organisation)
    Factory(:petition, user: user, organisation: @current_organisation,
                                   location: Factory(:location, locality: 'Museum', latitude: -33.876473, longitude: 151.209683),
                                   admin_status: :awesome, effort: @effort)
    Factory(:petition, user: user, organisation: @current_organisation,
                                   location: Factory(:location, locality: 'Manly', latitude: -33.797944, longitude: 151.285686),
                                   admin_status: :awesome, effort: @effort)
    Petition.index
  end

  it 'searches', js: true do
    visit effort_path(@effort)

    page.should have_content 'Museum'
    page.should have_content 'Manly'
    find('.thumbnails li div').text.should == 'Manly'

    fill_in 'location_query', with: 'Sydney'
    click_on 'search-effort'

    wait_until(5) do
      find('.thumbnails li div').text == 'Museum'
    end
  end
end
