require "test_helper"

class VerificationMailerTest < ActionMailer::TestCase
  test "send_verification_code" do
    user = users(:two)
    user.generate_verification_code!
    
    mail = VerificationMailer.send_verification_code(user)
    assert_equal "Код подтверждения", mail.subject
    assert_equal [user.email], mail.to
    assert_match user.verification_code, mail.text_part.body.to_s
  end
end
