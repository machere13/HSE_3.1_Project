class DynamicSmtpMailer < ApplicationMailer
  def self.send_with_dynamic_smtp(email, &block)
    smtp_config = SmtpConfigService.get_smtp_config(email)
    
    ActionMailer::Base.smtp_settings = smtp_config
    
    begin
      yield
    ensure
      ActionMailer::Base.smtp_settings = Rails.application.config.action_mailer.smtp_settings
    end
  end
end
