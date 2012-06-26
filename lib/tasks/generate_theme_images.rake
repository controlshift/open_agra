require 'csv'

desc "Change images hue to match different accent"
task :generate_theme_images do
  sat = ENV['SAT'].nil? ? 100 : ENV['SAT'].to_i
  raise 'Saturation value must between 0-200' if sat < 0 || sat > 200
  
  hue = ENV['HUE'].nil? ? 100 : ENV['HUE'].to_i
  raise 'Hue value must between 0-200' if hue < 0 || hue > 200
  
  org = ENV['ORGANISATION']
  raise 'Please specify organisation slug' if org.nil?
  
  images = [
    'header-arrow.png', 
    'btn-icon-flag.png',
    'bg-progress-done.png',
    'bg-progress-done-s.png',
    'btn-home-main.png',
    'btn-icon-login.png',
    'btn-icon-logout.png',
    'btn-icon-start-petition.png',
    'btn-icon-user.png',
    'bullet-orange-left-s.png',
    'bullet-orange-s.png'
  ]
  
  images.each do |image|
    puts image
    system "convert app/assets/images/#{image} -modulate 100,#{sat},#{hue} app/assets/images/organisations/#{org}/#{image}"
  end
end