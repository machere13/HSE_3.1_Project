# Preview all emails at http://localhost:3000/rails/mailers/verification_mailer
class VerificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/verification_mailer/send_verification_code
  def send_verification_code
    VerificationMailer.send_verification_code
  end
end
