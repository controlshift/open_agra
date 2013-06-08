## Moonshine Denyhosts

A simple Moonshine plugin for managing denyhosts.

### Installation

    # Rails 2
    script/plugin install git://github.com/railsmachine/moonshine_denyhosts.git --force
    # Rails 3
    script/rails plugin install git://github.com/railsmachine/moonshine_denyhosts.git --force

Configure as necessary in your moonshine.yml (or stage-specific moonshine yml):

    :denyhosts:
      :allow:
        - 'ALL : 127.0.0.1'
        - 'sshd : 1.2.3.4'
      :deny:
        - 'sshd : PARANOID'

For a full list of options and their default values, see `lib/moonshine/denyhosts/default_configuration.yml`.

Next, add the recipe to the manifests in question:

    # app/manifests/application_manifest.rb
    recipe :denyhosts


### Deploying

That's it. Deploy and done!
