class Petitions::CountriesController < ApplicationController
  layout 'application_sidebar'
  skip_before_filter :authenticate_user!
  before_filter :assign_countries
  before_filter :load_country, only: [:show, :embed, :iframe]

  def show
    if @country
      query = Queries::Petitions::CountryQuery.new(organisation: current_organisation, country: params[:id])
      query.execute!
      @petitions =  query.petitions
    else
      render_not_found
    end
  end

  def embed
    render_not_found if @country.blank?
  end

  def iframe
    if @country.present?
      render :iframe, layout: 'iframe'
    else
      render_not_found
    end
  end


  private
  def load_country
    @country = Country.find_by(:iso, params[:id])
  end

  def assign_countries
    @countries = current_organisation.petitions.appropriate.joins(:location).select('petitions.updated_at as updated_at, locations.country as location_country').order('location_country ASC').uniq.map(&:location_country).uniq.compact
  end
end
