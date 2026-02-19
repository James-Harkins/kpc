class GolferMailer < ApplicationMailer
  def password_reset(golfer, token)
    @golfer = golfer
    @reset_url = edit_password_reset_url(token)
    mail(to: @golfer.email, subject: "KPC Password Reset")
  end
end
