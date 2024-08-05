class PaymentsController < ApplicationController
  def create
    golfer_trip = GolferTrip.find(params[:golfer_trip_id])
    amount = params[:amount].to_i
    if amount <= golfer_trip.balance 
      payment = Payment.create!(golfer_trip: golfer_trip, amount: amount)
      golfer_trip.balance = golfer_trip.balance - amount
      golfer_trip.save
      if golfer_trip.balance == 0
        golfer_trip.is_paid = true 
        golfer_trip.save
      end
      redirect_to "/dashboard"
    else
      redirect_to "/dashboard"
      flash[:error] = "Payment cannot be greater than outstanding balance."
    end
  end
end
