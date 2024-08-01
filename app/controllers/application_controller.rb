class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    golfer = Golfer.find(session[:email]) if session[:email]
  end
end
