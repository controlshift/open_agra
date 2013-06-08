module Sysctl
  TEMPLATES_DIR = File.join(File.dirname(__FILE__), '..', 'templates')

  def sysctl(hash = {})
    file '/etc/sysctl.d/99-moonshine.conf',
      :ensure => :present,
      :mode => 644,
      :content => template(File.join(TEMPLATES_DIR, 'sysctl.erb'), binding)

    # update the sysctl params when they change
    exec 'invoke-rc.d procps start',
      :subscribe => file('/etc/sysctl.d/99-moonshine.conf'),
      :refreshonly => true
  end

end