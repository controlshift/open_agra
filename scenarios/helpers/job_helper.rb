module JobHelper
  def should_have_job(jobs, pattern) 
    jobs.each do |job|
      return true if job.handler.match(/#{pattern}/) 
    end
    return false
  end

  def should_notify_partner_org
    
  end
end
