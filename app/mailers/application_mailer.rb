class ApplicationMailer < ActionMailer::Base
  default from: "\"Team Oregon Website\" <#{ENV.fetch('TEAMO_CONTACT_FORM_FROM', 'no-reply@test.example')}>"
  layout 'mailer'
end
