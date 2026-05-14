class ReturnsController < ApplicationController
  before_action :require_site_admin

  def create
    golfer_trip = GolferTrip.find(params[:golfer_trip_id])
    amount = params[:amount].to_i
    if amount > 0
      Payment.create!(golfer_trip: golfer_trip, amount: -amount)
      total_paid = golfer_trip.payments.sum(:amount)
      golfer_trip.balance = [golfer_trip.cost - total_paid, 0].max
      golfer_trip.is_paid = golfer_trip.balance == 0
      golfer_trip.save!
    else
      flash[:error] = "Return amount must be greater than zero."
    end
    redirect_to "/finances?trip_id=#{golfer_trip.trip_id}"
  end
end
