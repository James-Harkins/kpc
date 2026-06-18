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
end
