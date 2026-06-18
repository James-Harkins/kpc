class PasswordResetsController < ApplicationController
  before_action :load_golfer_by_token, only: [:edit, :update]

  def new
  end

  def create
    golfer = Golfer.find_by(email: params[:email].downcase.strip)
    if golfer
      token = golfer.generate_password_reset_token!
      GolferMailer.password_reset(golfer, token).deliver_now
    end
    flash[:notice] = "If that email is registered, you'll receive a reset link shortly."
    redirect_to "/login"
  end

  def edit
  end

  def update
    expired = @golfer.welcome_token ? @golfer.welcome_token_expired? : @golfer.password_reset_expired?
    if expired
      flash[:error] = "That reset link has expired. Please request a new one."
      redirect_to "/forgot_password"
    else
      was_welcome_token = @golfer.welcome_token
      updated = false
      ActiveRecord::Base.transaction do
        updated = @golfer.update(password_params)
        if updated
          columns = { password_reset_token: nil, password_reset_sent_at: nil }
          columns[:welcome_token] = false if was_welcome_token
          @golfer.update_columns(columns)
        end
      end
      if updated
        flash[:notice] = "Password updated! Please log in."
        redirect_to "/login"
      else
        render :edit
      end
    end
  end

  private

  def load_golfer_by_token
    hashed = Digest::SHA256.hexdigest(params[:token])
    @golfer = Golfer.find_by(password_reset_token: hashed)
    unless @golfer
      flash[:error] = "Invalid or expired reset link."
      redirect_to "/forgot_password"
    end
  end

  def password_params
    params.require(:golfer).permit(:password, :password_confirmation)
  end
end
