class TripFinancialSummariesController < ApplicationController
  before_action :require_admin

  def create
    trip      = Trip.find(params[:trip_id])
    breakdown = trip.admin_cost_breakdown
    count     = breakdown.length
    deficit   = trip.admin_net_deficit

    summary = TripFinancialSummary.find_or_initialize_by(trip_id: trip.id)
    summary.update!(
      total_revenue:   trip.total_projected_revenue,
      total_expenses:  trip.total_expenses,
      total_deficit:   deficit,
      fair_share:      count > 0 ? (deficit.to_f / count).round : 0,
      committee_count: count
    )

    redirect_to finances_path(trip_id: trip.id)
  end
end
