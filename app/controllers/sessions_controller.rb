class SessionsController < ApplicationController
  def new
  end

  def create
    golfer = Golfer.find_by(email: params[:email])
    if golfer
      if golfer.authenticate(params[:password])
        session[:golfer_id] = golfer.id
        redirect_to "/dashboard"
      else
        flash[:error] = "Try again, fucko!"
        redirect_to "/login"
      end
    else
      flash[:error] = "Sign up first, fucko!"
      redirect_to "/login"
    end
  end

  def destroy
    session.destroy
    redirect_to "/"
  end
end
