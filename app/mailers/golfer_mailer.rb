class GolferMailer < ApplicationMailer
  def password_reset(golfer)
    @golfer = golfer
    @reset_url = edit_password_reset_url(@golfer.password_reset_token)
    mail(to: @golfer.email, subject: "KPC Password Reset")
  end
end
