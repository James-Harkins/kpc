class PaymentsController < ApplicationController
  before_action :require_admin

  def create
    golfer_trip = GolferTrip.find(params[:golfer_trip_id])
    amount = params[:amount].to_i
    if amount > 0 && amount <= golfer_trip.balance
      payment = Payment.create!(golfer_trip: golfer_trip, amount: amount)
      total_paid = golfer_trip.payments.sum(:amount)
      golfer_trip.balance = [golfer_trip.cost - total_paid, 0].max
      golfer_trip.is_paid = golfer_trip.balance == 0
      golfer_trip.save!
      if golfer_trip.is_paid
        GolferMailer.balance_paid(golfer_trip.golfer, golfer_trip).deliver_now
      else
        GolferMailer.payment_received(golfer_trip.golfer, golfer_trip, payment).deliver_now
      end
    else
      flash[:error] = "Payment must be greater than $0 and no more than the outstanding balance."
    end
    redirect_to "/finances?trip_id=#{golfer_trip.trip_id}"
  end
end
