class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    golfer = Golfer.find(session[:golfer_id]) if session[:golfer_id]
  end
end
