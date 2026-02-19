class PaymentsController < ApplicationController
  before_action :require_admin

  def create
    golfer_trip = GolferTrip.find(params[:golfer_trip_id])
    amount = params[:amount].to_i
    if amount <= golfer_trip.balance
      Payment.create!(golfer_trip: golfer_trip, amount: amount)
      golfer_trip.balance = golfer_trip.balance - amount
      golfer_trip.save
      if golfer_trip.balance == 0
        golfer_trip.is_paid = true
        golfer_trip.save
      end
    else
      flash[:error] = "Payment cannot be greater than outstanding balance."
    end
    redirect_to "/finances?trip_id=#{golfer_trip.trip_id}"
  end
end
