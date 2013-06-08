Agra::Application.configure do
  if ENV["S3_ENABLED"]
    ActionController::Base.asset_host = ENV["S3_HOST_ALIAS"]

    config.paperclip_options = {
      storage: :s3,
      s3_host_alias: ENV["S3_HOST_ALIAS"],
      url: ':s3_alias_url',
      path: "/:class/:attachment/:id/:style/:filename",
      s3_credentials: {url: :s3_alias_url, access_key_id: ENV["S3_KEY"], secret_access_key: ENV["S3_SECRET"], bucket: ENV["S3_BUCKET"], s3_host_name: ENV["S3_REGION"]},
      s3_headers: { 'Cache-Control' => 'public, max-age=1314000' }
    }
    config.paperclip_file_options = config.paperclip_options.merge({
      path: "/:class/:attachment/:id/:timestamp/:filename"
    })
  else
    config.paperclip_options = {
      url: "/system/:class/:attachment/:id/:style/:filename",
      storage: :filesystem
    }
    config.paperclip_file_options = config.paperclip_options.merge({
      url: "/system/:class/:attachment/:id/:timestamp/:filename"
    })
  end
end
