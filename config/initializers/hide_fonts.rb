# capybara-webkit has issues with fonts
# https://github.com/thoughtbot/capybara-webkit/issues/181

if Rails.env.test?
  Rails.application.config.assets.paths.reject! do |path|
    path.to_s =~ /fonts/
  end
end