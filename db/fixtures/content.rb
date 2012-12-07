# Content.rb contains all the CMS of the application.
# rake db:seed_fu is used to populate the table with the content.
# cf('slug') is used in the view to get the body of a content.
# Class Content contains categories in case you want to add a new category.

def load_content(slug)
  IO.read(File.join(Rails.root, 'db', 'fixtures', 'content', "#{slug}.txt")) 
end
Content.seed(:slug, :organisation_id,

  { slug: 'about_us',                 body: load_content('about_us'),                 category: 'Footer', name: 'About Us'},
  { slug: 'tos',                      body: load_content('tos'),                      category: 'Footer', name: 'Terms of Service'},
  { slug: 'privacy_policy',           body: load_content('privacy_policy'),           category: 'Footer', name: 'Privacy Policy'},
  { slug: 'community',                body: load_content('community'),                category: 'Footer', name: 'Community'},
  { slug: 'media',                    body: load_content('media'),                    category: 'Footer', name: 'Media'},
  { slug: 'homepage_headline',        body: load_content('homepage_headline'),        category: 'Home', name: 'Homepage Headline'},
  { slug: 'homepage_explainer',       body: load_content('homepage_explainer'),       category: 'Home', name: 'Site Explanation'},
  { slug: 'petition_manage_forum',    body: load_content('petition_manage_forum'),    category: 'Petition Manage', name: 'Forum'},
  { slug: 'petition_manage_email_label',      body: load_content('petition_manage_email_label'),      category: 'Petition Manage', name: 'Email Supporters Label'},
  { slug: 'petition_manage_email_popover',    body: load_content('petition_manage_email_popover'),    category: 'Petition Manage', name: 'Email Supporters Popover'},
  { slug: 'petition_manage_offline_label',    body: load_content('petition_manage_offline_label'),    category: 'Petition Manage', name: 'Offline Signatures Label'},
  { slug: 'petition_manage_offline_popover',  body: load_content('petition_manage_offline_popover'),  category: 'Petition Manage', name: 'Offline Signatures Popover'},
  { slug: 'petition_manage_offline_content',  body: load_content('petition_manage_offline_content'),  category: 'Petition Manage', name: 'Offline Signatures Page Content'},
  { slug: 'petition_manage_delivery_label',   body: load_content('petition_manage_delivery_label'),   category: 'Petition Manage', name: 'Delivery Petition Label'},
  { slug: 'petition_manage_delivery_popover', body: load_content('petition_manage_delivery_popover'), category: 'Petition Manage', name: 'Delivery Petition Popover'},
  { slug: 'petition_manage_delivery_content', body: load_content('petition_manage_delivery_content'), category: 'Petition Manage', name: 'Delivery Petition Page Content'},
  { slug: 'petition_manage_edit_label',       body: load_content('petition_manage_edit_label'),       category: 'Petition Manage', name: 'Edit Petition Label'},
  { slug: 'petition_manage_edit_popover',     body: load_content('petition_manage_edit_popover'),     category: 'Petition Manage', name: 'Edit Petition Popover'},
  { slug: 'petition_manage_contact_label',    body: load_content('petition_manage_contact_label'),    category: 'Petition Manage', name: 'Contact Org Label'},
  { slug: 'petition_manage_hide_label',       body: load_content('petition_manage_hide_label'),       category: 'Petition Manage', name: 'Hide Petition Label'},
  { slug: 'petition_manage_hide_popover',     body: load_content('petition_manage_hide_popover'),     category: 'Petition Manage', name: 'Hide Petition Popover'},
  { slug: 'petition_manage_reactivate_label', body: load_content('petition_manage_reactivate_label'), category: 'Petition Manage', name: 'Reactivate Petition Label'},
  { slug: 'petition_form_title_help', body: "What's your petition trying to do? Remember people can't sign on to something they don't understand so keep it short, simple and punchy. e.g.:Don't build a Coal Seam Gas mine in Newtown.", category: 'Petitions', name: 'Form Help for Petition Title Field'},
  { slug: 'petition_form_whom_help',  body: "Who has the power to give you what you want? MPs, CEOs, the Prime Minister, the Mayor etc.", category: 'Petitions', name: 'Form Help for Petition Whom Field'},
  { slug: 'petition_form_what_help',  body: "This is what you would write in a letter to your target. i.e. Dear Minister, please don't approve a coal seam gas mine in Newtown etc.", category: 'Petitions', name: 'Form Help for Petition What Field'},
  { slug: 'petition_form_why_help',   body: "This is what you'd say to a friend if you were trying to explain why you cared about this issue. Try to use a combination of facts and stories so you appeal to people's heads and hearts.", category: 'Petitions', name: 'Form Help for Petition Why Field'},
  { slug: 'petition_form_where_help',   body: 'A location that your petition relates to. State, city, neighborhood or address.', category: 'Petitions', name: 'Form Help for Petition Where Field'},
  { slug: 'welcome_email',                            body: load_content('welcome_email'),                            category: 'Email', name: 'Welcome email for new campaigns',         filter: 'liquid' },
  { slug: 'promote_petition_send_launch_kicker',      body: load_content('promote_petition_send_launch_kicker'),      category: 'Email', name: 'Promote Email: Launch Kicker',            filter: 'liquid' },
  { slug: 'promote_petition_encourage',               body: load_content('promote_petition_encourage'),               category: 'Email', name: 'Promote Email: Encourage',                filter: 'liquid' },
  { slug: 'promote_petition_reminder_when_dormant',   body: load_content('promote_petition_reminder_when_dormant'),   category: 'Email', name: 'Promote Email: Reminder When Dormant',    filter: 'liquid' },
  { slug: 'promote_petition_achieved_signature_goal', body: load_content('promote_petition_achieved_signature_goal'), category: 'Email', name: 'Promote Email: Achieved Signature Goal',  filter: 'liquid' },
  { slug: 'signature_thank_you_email',                body: load_content('signature_thank_you_email'),                category: 'Email', name: 'Thank you email for new signers',         filter: 'liquid' },
  { slug: 'signature_thank_you_email_forward',        body: load_content('signature_thank_you_email_forward'),        category: 'Email', name: 'Forward after signing email',             filter: 'liquid' },
  { slug: 'twitter_share_text',   body: 'This cause is close to my heart - please sign:', category: 'Social', name: 'Twitter Share Text'},
  { slug: 'petition_landing_aside',         body: load_content('petition_landing_aside'), category: 'Petition Landing', name: 'Aside'},
  { slug: 'petition_landing_description',   body: "Your campaign to make Australia better begins here.  We'll help you with tools and advice every step of the way.", category: 'Petition Landing', name: 'Description'},
  { slug: 'petition_landing_title',         body: 'Start A Campaign', category: 'Petition Landing', name: 'Title'},

  { slug: 'email_template_share_on_social_media', body: load_content('email_template_share_on_social_media'),   category: 'Email', kind: 'email_template', filter: 'liquid', name: 'Share on social media'},
  { slug: 'email_template_we_had_a_win',          body: load_content('email_template_we_had_a_win'),            category: 'Email', kind: 'email_template', filter: 'liquid', name: 'We had a win'},
  { slug: 'email_template_report_back',           body: load_content('email_template_report_back'),             category: 'Email', kind: 'email_template', filter: 'liquid', name: 'Report back'},
  { slug: 'email_template_delivery',              body: load_content('email_template_delivery'),                category: 'Email', kind: 'email_template', filter: 'liquid', name: 'Delivery'},

  { slug: 'petition_show_postcode_label', body: 'Postcode', category: 'Petitions', name: 'Postcode Label'  },
  { slug: 'leader_duties_text',    body: load_content('leader_duties_text'),   category: 'Efforts', name: 'Leader duty',          filter: 'liquid'  },
  { slug: 'how_this_works_text',   body: load_content('how_this_works_text'),  category: 'Efforts', name: 'Specific target help', filter: 'liquid'  },
  { slug: 'training_text',         body: load_content('training_text'),        category: 'Efforts', name: 'Training text',        filter: 'liquid'  },
  { slug: 'training_sidebar_text', body: load_content('training_sidebar_text'),category: 'Efforts', name: 'Training sidebar text',filter: 'liquid'  }
)

