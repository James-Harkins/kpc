class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    Golfer.find(session[:golfer_id]) if session[:golfer_id]
  end

  private

  def require_login
    unless current_user
      flash[:login] = "Log in first, Fucko!"
      redirect_to "/login"
    end
  end

  def require_admin
    require_login
    return if performed?
    unless current_user.admin?
      flash[:login] = "Admins only, Fucko!"
      redirect_to "/dashboard"
    end
  end

  def require_non_admin
    require_login
    return if performed?
    if current_user.admin?
      flash[:login] = "Not for admins, Fucko!"
      redirect_to "/dashboard"
    end
  end

  def require_site_admin
    require_login
    return if performed?
    site_admin = Golfer.where(email: ENV["SITE_ADMIN_EMAIL"]).first
    unless site_admin && current_user == site_admin
      flash[:login] = "Site admin only, Fucko!"
      redirect_to "/dashboard"
    end
  end
end
