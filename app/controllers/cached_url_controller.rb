 require 'net/http'
class CachedUrlController < ApplicationController
  skip_before_filter :authenticate_user!, :all
  skip_before_filter :prepend_organisation_view_path, :all

  def retrieve
    if params[:uri] && params[:urls]
      request_path = "/#{params[:uri]}?#{request.query_string}&key=#{EMBEDLY_KEY}"
      json = Rails.cache.fetch(cache_key, expires_in: 1.day) { http_get(request_path) }
      expires_in 1.day, :public => true
      render json: adjust_callback(json, params[:callback])
    else
      head :not_found
    end
  end

  private

  def cache_key
    "embedly_#{Digest::MD5.hexdigest(params[:urls])}"
  end

  def adjust_callback(json, new_method_name)
    json.gsub(/jQuery\d+_\d+/, new_method_name)
  end

  def http_get(path)
    Net::HTTP.get_response("api.embed.ly", path).body
  end
end
