# This patch solves the problem on Heroku with Delayed Job. We could not send any email with the delayed job.
# This patch has been taken from the DelayedJob github.
# https://github.com/collectiveidea/delayed_job/commit/023444424166ba2ce011bfe2d47954e79edf6798
# I guess this commit will be included in the next version of DelayedJob.

require 'delayed_job'

class Module
  def self.yaml_new(klass, tag, val)
    val.constantize
  end
end
