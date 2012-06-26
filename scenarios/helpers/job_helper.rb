module JobHelper
  def should_have_job(jobs, pattern) 
    jobs.each do |job|
      return true if job.handler.match(/#{pattern}/) 
    end
    return false
  end

  def should_notify_partner_org
    should_have_job(Delayed::Job.all, 'notify_sign_up')
    worker_failures = Delayed::Worker.new.work_off(1000)[1]
    worker_failures.should == 0
  end
end
