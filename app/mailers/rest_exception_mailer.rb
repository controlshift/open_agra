class RestExceptionMailer < ActionMailer::Base
  default :from => "info@controlshiftlabs.com"

  def exception_email(e, params)
    @exception = e
    @params = params
    mail(:to => %w{controlshift-dev@googlegroups.com woodhull@gmail.com}, :subject => "REST Exception")
  end
end