# Sends one GolferMailer message per golfer, spaced out to stay under Resend's
# rate limit. Used for any mail that goes to many people so the web request
# that triggers it returns immediately.
class BulkMailJob < ApplicationJob
  queue_as :default

  SEND_INTERVAL = 0.6

  def perform(mailer_method, golfer_ids, *args)
    Golfer.where(id: golfer_ids).find_each do |golfer|
      begin
        GolferMailer.public_send(mailer_method, golfer, *args).deliver_now
      rescue StandardError => e
        Rails.logger.error("BulkMailJob #{mailer_method} to golfer #{golfer.id} failed: #{e.class}: #{e.message}")
      end
      sleep(SEND_INTERVAL)
    end
  end
end
