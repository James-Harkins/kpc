class BedAlertOptOut < ApplicationRecord
  belongs_to :golfer
  belongs_to :trip

  validates :golfer_id, uniqueness: { scope: :trip_id }

  def self.verifier
    Rails.application.message_verifier(:bed_alert_opt_out)
  end

  def self.token_for(golfer, trip)
    verifier.generate([golfer.id, trip.id])
  end

  # Returns the [golfer, trip] a token was issued for, or nil if the token is
  # tampered with or no longer points at real records.
  def self.parties_for(token)
    golfer_id, trip_id = verifier.verify(token.to_s)
    golfer = Golfer.find_by(id: golfer_id)
    trip   = Trip.find_by(id: trip_id)
    [golfer, trip] if golfer && trip
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end
