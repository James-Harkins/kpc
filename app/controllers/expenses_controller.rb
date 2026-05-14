class ExpensesController < ApplicationController
  before_action :require_admin
  before_action :set_trip
  before_action :set_expense, only: [:edit, :update, :destroy]
  before_action :set_admin_golfers, only: [:new, :create, :edit, :update]

  def index
    @expenses = @trip.expenses.order(:date)
  end

  def new
    @expense = @trip.expenses.build
  end

  def create
    @expense = @trip.expenses.build(expense_params)
    if @expense.save
      redirect_to expenses_path(trip_id: @trip.id)
    else
      flash[:error] = @expense.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path(trip_id: @trip.id)
    else
      flash[:error] = @expense.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path(trip_id: @trip.id)
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end

  def set_expense
    @expense = @trip.expenses.find(params[:id])
  end

  def set_admin_golfers
    @admin_golfers = Golfer.where(role: :admin).order(:last_name, :first_name)
  end

  def expense_params
    params.require(:expense).permit(:date, :amount, :description, :golfer_id)
  end
end
