# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120524075209) do

  create_table "campaign_admins", :force => true do |t|
    t.integer "petition_id"
    t.integer "user_id"
    t.string  "invitation_email"
    t.string  "invitation_token", :limit => 60
  end

  add_index "campaign_admins", ["petition_id", "user_id"], :name => "index_campaign_admins_on_petition_id_and_user_id"
  add_index "campaign_admins", ["user_id", "petition_id"], :name => "index_campaign_admins_on_user_id_and_petition_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organisation_id"
    t.string   "slug"
  end

  add_index "categories", ["organisation_id"], :name => "index_categories_on_organisation_id"
  add_index "categories", ["slug"], :name => "index_categories_on_slug"

  create_table "categorized_petitions", :force => true do |t|
    t.integer  "category_id"
    t.integer  "petition_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "categorized_petitions", ["category_id"], :name => "index_categorized_petitions_on_category_id"

  create_table "contents", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "slug"
    t.string   "name"
    t.string   "category"
    t.text     "body"
    t.string   "filter",          :default => "none"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "contents", ["category"], :name => "index_contents_on_category"
  add_index "contents", ["slug", "organisation_id"], :name => "index_contents_on_slug_and_organisation_id", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "efforts", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.text     "gutter_text"
    t.string   "title_help"
    t.string   "title_label"
    t.text     "title_default"
    t.string   "who_help"
    t.string   "who_label"
    t.text     "who_default"
    t.string   "what_help"
    t.string   "what_label"
    t.text     "what_default"
    t.string   "why_help"
    t.string   "why_label"
    t.text     "why_default"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "thanks_for_creating_email"
    t.boolean  "ask_for_location"
  end

  add_index "efforts", ["organisation_id"], :name => "index_efforts_on_organisation_id"
  add_index "efforts", ["slug"], :name => "index_efforts_on_slug"

  create_table "email_white_lists", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "email_white_lists", ["email"], :name => "index_email_white_lists_on_email"

  create_table "emails", :force => true do |t|
    t.string   "to_address",   :null => false
    t.string   "from_name",    :null => false
    t.string   "from_address", :null => false
    t.string   "subject",      :null => false
    t.text     "content",      :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "group_members", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.string  "invitation_email"
    t.string  "invitation_token", :limit => 60
  end

  add_index "group_members", ["group_id", "user_id"], :name => "index_group_members_on_group_id_and_user_id"
  add_index "group_members", ["user_id", "group_id"], :name => "index_group_members_on_user_id_and_group_id"

  create_table "groups", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "groups", ["organisation_id"], :name => "index_groups_on_organisation_id"
  add_index "groups", ["slug"], :name => "index_groups_on_slug"

  create_table "locations", :force => true do |t|
    t.string   "query"
    t.decimal  "latitude",    :precision => 13, :scale => 10
    t.decimal  "longitude",   :precision => 13, :scale => 10
    t.string   "street"
    t.string   "locality"
    t.string   "postal_code"
    t.string   "country"
    t.string   "region"
    t.string   "warning"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.text     "extras"
  end

  add_index "locations", ["latitude", "longitude"], :name => "index_locations_on_latitude_and_longitude"
  add_index "locations", ["query"], :name => "index_locations_on_query"

  create_table "organisations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "slug"
    t.string   "host"
    t.string   "contact_email"
    t.string   "parent_name"
    t.string   "admin_email"
    t.string   "google_analytics_tracking_id"
    t.string   "blog_link"
    t.string   "notification_url"
    t.string   "sendgrid_username"
    t.string   "sendgrid_password"
    t.string   "campaigner_feedback_link"
    t.string   "user_feedback_link"
    t.boolean  "use_white_list",               :default => false
    t.string   "parent_url"
    t.string   "facebook_url"
    t.string   "twitter_account_name"
    t.text     "settings"
    t.string   "uservoice_widget_link"
  end

  add_index "organisations", ["host"], :name => "index_organisations_on_host", :unique => true
  add_index "organisations", ["slug"], :name => "index_organisations_on_slug", :unique => true

  create_table "petition_blast_emails", :force => true do |t|
    t.integer  "petition_id"
    t.string   "from_name",                                :null => false
    t.string   "from_address",                             :null => false
    t.string   "subject",                                  :null => false
    t.text     "body",                                     :null => false
    t.integer  "delayed_job_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "recipient_count"
    t.string   "moderation_status", :default => "pending"
    t.string   "delivery_status",   :default => "pending"
    t.datetime "moderated_at"
    t.string   "moderation_reason"
  end

  add_index "petition_blast_emails", ["petition_id", "created_at"], :name => "index_petition_blast_emails_on_petition_id_and_created_at"

  create_table "petition_flags", :force => true do |t|
    t.integer  "petition_id"
    t.integer  "user_id"
    t.string   "ip_address"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "petition_flags", ["ip_address"], :name => "index_petition_flags_on_ip_address"
  add_index "petition_flags", ["petition_id"], :name => "index_petition_flags_on_petition_id"
  add_index "petition_flags", ["user_id"], :name => "index_petition_flags_on_user_id"

  create_table "petitions", :force => true do |t|
    t.string   "title"
    t.string   "who"
    t.text     "why"
    t.text     "what"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "user_id"
    t.string   "slug"
    t.integer  "organisation_id",                                  :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "delivery_details"
    t.boolean  "cancelled",              :default => false,        :null => false
    t.string   "token"
    t.string   "admin_status",           :default => "unreviewed"
    t.boolean  "launched",               :default => false,        :null => false
    t.boolean  "campaigner_contactable", :default => true
    t.text     "admin_reason"
    t.datetime "administered_at"
    t.integer  "effort_id"
    t.text     "admin_notes"
    t.string   "source"
    t.integer  "group_id"
    t.integer  "location_id"
  end

  add_index "petitions", ["effort_id"], :name => "index_petitions_on_effort_id"
  add_index "petitions", ["group_id"], :name => "index_petitions_on_group_id"
  add_index "petitions", ["location_id"], :name => "index_petitions_on_location_id"
  add_index "petitions", ["organisation_id", "admin_status", "launched", "cancelled", "user_id", "updated_at"], :name => "homepage_optimization", :order => {"updated_at"=>:desc}
  add_index "petitions", ["slug"], :name => "index_petitions_on_slug", :unique => true
  add_index "petitions", ["token"], :name => "index_petitions_on_token", :unique => true
  add_index "petitions", ["user_id"], :name => "index_petitions_on_user_id"

  create_table "signatures", :force => true do |t|
    t.integer  "petition_id"
    t.string   "email",             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "postcode"
    t.datetime "created_at"
    t.boolean  "join_organisation"
    t.datetime "deleted_at"
    t.string   "token"
    t.datetime "unsubscribe_at"
  end

  add_index "signatures", ["email", "petition_id"], :name => "index_signatures_on_email_and_petition_id", :unique => true
  add_index "signatures", ["petition_id", "deleted_at", "unsubscribe_at"], :name => "visible_petitions"
  add_index "signatures", ["token"], :name => "index_signatures_on_token", :unique => true

  create_table "stories", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "featured"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "organisation_id"
  end

  add_index "stories", ["organisation_id", "featured"], :name => "index_stories_on_organisation_id_and_featured"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin"
    t.string   "phone_number"
    t.string   "postcode"
    t.boolean  "join_organisation"
    t.integer  "organisation_id",                                          :null => false
    t.boolean  "org_admin",                             :default => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "opt_out_site_email"
    t.string   "facebook_id"
  end

  add_index "users", ["email", "organisation_id"], :name => "index_users_on_email_and_organisation_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vanity_conversions", :force => true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], :name => "by_experiment_id_and_alternative"

  create_table "vanity_experiments", :force => true do |t|
    t.string   "experiment_id"
    t.integer  "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "vanity_experiments", ["experiment_id"], :name => "index_vanity_experiments_on_experiment_id"

  create_table "vanity_metric_values", :force => true do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string  "date"
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], :name => "index_vanity_metric_values_on_vanity_metric_id"

  create_table "vanity_metrics", :force => true do |t|
    t.string   "metric_id"
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], :name => "index_vanity_metrics_on_metric_id"

  create_table "vanity_participants", :force => true do |t|
    t.string  "experiment_id"
    t.string  "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
  end

  add_index "vanity_participants", ["experiment_id", "converted"], :name => "by_experiment_id_and_converted"
  add_index "vanity_participants", ["experiment_id", "identity"], :name => "by_experiment_id_and_identity"
  add_index "vanity_participants", ["experiment_id", "seen"], :name => "by_experiment_id_and_seen"
  add_index "vanity_participants", ["experiment_id", "shown"], :name => "by_experiment_id_and_shown"
  add_index "vanity_participants", ["experiment_id"], :name => "index_vanity_participants_on_experiment_id"

  add_foreign_key "petitions", "organisations", :name => "petitions_organisation_id_fk"

  add_foreign_key "users", "organisations", :name => "users_organisation_id_fk"

end
