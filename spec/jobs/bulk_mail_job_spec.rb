require 'rails_helper'

RSpec.describe BulkMailJob do
  let(:trip) { create(:trip) }
  let!(:golfers) { create_list(:golfer, 3) }

  before do
    allow_any_instance_of(described_class).to receive(:sleep)
    ActionMailer::Base.deliveries.clear
  end

  it 'sends one message per golfer, throttled' do
    expect_any_instance_of(described_class).to receive(:sleep).with(BulkMailJob::SEND_INTERVAL).exactly(3).times
    described_class.perform_now('announcement', golfers.map(&:id), 'Subject', 'Body', trip)
    expect(ActionMailer::Base.deliveries.flat_map(&:to)).to match_array(golfers.map(&:email))
  end

  it 'only sends to the golfers it is given' do
    described_class.perform_now('announcement', [golfers.first.id], 'Subject', 'Body', trip)
    expect(ActionMailer::Base.deliveries.map(&:to)).to eq([[golfers.first.email]])
  end

  it 'keeps sending after one delivery fails' do
    calls = 0
    allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now) do
      calls += 1
      raise Net::SMTPFatalError, 'boom' if calls == 1
    end
    expect(Rails.logger).to receive(:error).with(/failed: Net::SMTPFatalError/)
    described_class.perform_now('announcement', golfers.map(&:id), 'Subject', 'Body', trip)
    expect(calls).to eq(3)
  end
end
