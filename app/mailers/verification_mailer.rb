class VerificationMailer < ApplicationMailer
  def send_verification_code(user)
    @user = user
    @verification_code = user.verification_code

    DynamicSmtpMailer.send_with_dynamic_smtp(@user.email) do
      mail(
        from: ENV['DEFAULT_EMAIL_USERNAME'],
        to: @user.email, 
        subject: 'Код подтверждения'
      )
    end
  end
end
