require 'rails_helper'

RSpec.describe GolferMailer, type: :mailer do
  let!(:golfer) do
    Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                   email: 't@badabing.com', password: 'test1234',
                   password_confirmation: 'test1234', t_shirt_size: :m)
  end

  describe '#welcome' do
    let(:raw_token) { 'my_raw_reset_token' }
    let(:mail) { GolferMailer.welcome(golfer, raw_token) }

    it 'sends to the golfer email' do
      expect(mail.to).to eq([golfer.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Welcome to Kitchen Pass Classic')
    end

    it 'includes the raw token in the body (for the set-password link)' do
      expect(mail.body.encoded).to include(raw_token)
    end

    it 'addresses the golfer by first name in the body' do
      expect(mail.body.encoded).to include(golfer.first_name)
    end

    it 'addresses the golfer by nickname in the body' do
      expect(mail.body.encoded).to include(golfer.nickname)
    end
  end

  describe '#deposit_reminder' do
    let(:trip) { create(:trip, deposit_due_date: Date.new(2026, 6, 1)) }
    let(:golfer_trip) { create(:golfer_trip, golfer: golfer, trip: trip, cost: 400) }
    let(:mail) do
      create(:payment, golfer_trip: golfer_trip, amount: 50)
      GolferMailer.deposit_reminder(golfer, golfer_trip)
    end

    it 'sends to the golfer email' do
      expect(mail.to).to eq([golfer.email])
    end

    it 'has the deadline in the subject' do
      expect(mail.subject).to eq("KPC #{trip.number} - Deposit Due June 1")
    end

    it 'includes the remaining deposit amount in the body' do
      expect(mail.body.encoded).to include('150')
    end

    it 'mentions the non-refundable policy and bed incentive' do
      expect(mail.text_part.body.encoded).to include('NON-REFUNDABLE')
      expect(mail.text_part.body.encoded).to include('best beds')
    end
  end

  describe '#deposit_final_call' do
    let(:trip) { create(:trip, deposit_due_date: Date.new(2026, 6, 15)) }
    let(:golfer_trip) { create(:golfer_trip, golfer: golfer, trip: trip, cost: 400) }
    let(:mail) do
      create(:payment, golfer_trip: golfer_trip, amount: 50)
      GolferMailer.deposit_final_call(golfer, golfer_trip)
    end

    it 'sends to the golfer email with a due-today subject' do
      expect(mail.to).to eq([golfer.email])
      expect(mail.subject).to eq("KPC #{trip.number} - Deposit Due TODAY")
    end

    it 'includes the remaining deposit amount and the tier warning' do
      expect(mail.text_part.body.encoded).to include('150')
      expect(mail.text_part.body.encoded).to include('drop a tier')
    end
  end

  describe '#balance_final_notice' do
    let(:trip) { create(:trip) }
    let(:golfer_trip) { create(:golfer_trip, golfer: golfer, trip: trip, cost: 400, balance: 250) }
    let(:mail) { GolferMailer.balance_final_notice(golfer, golfer_trip) }

    it 'sends to the golfer email with a one-week-out subject' do
      expect(mail.to).to eq([golfer.email])
      expect(mail.subject).to eq("KPC #{trip.number} - One Week Out (Balance Due)")
    end

    it 'includes the outstanding balance and start date' do
      expect(mail.text_part.body.encoded).to include('250')
      expect(mail.text_part.body.encoded).to include(trip.start_date.strftime('%A, %B %-d'))
    end
  end
end
