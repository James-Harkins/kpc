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
        flash[:error] = "Try again, Fucko!"
        redirect_to "/login"
      end
    else
      flash[:error] = "Sign up first, Fucko!"
      redirect_to "/register"
    end
  end

  def destroy
    session.destroy
    redirect_to "/"
  end
end
