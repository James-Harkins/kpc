require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let!(:golfer) do
    Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                   email: 't@badabing.com', password: 'test1234',
                   password_confirmation: 'test1234', t_shirt_size: :m)
  end

  describe 'PATCH /password_resets/:token' do
    context 'when welcome_token is false (standard password reset flow)' do
      before { golfer.update_columns(welcome_token: false) }

      context 'with a non-expired token (sent within 2 hours)' do
        it 'updates the password and redirects to /login' do
          golfer.update_columns(password_reset_sent_at: 1.hour.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          expect(response).to redirect_to('/login')
        end

        it 'clears the password_reset_token after success' do
          golfer.update_columns(password_reset_sent_at: 1.hour.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          golfer.reload
          expect(golfer.password_reset_token).to be_nil
        end
      end

      context 'with an expired token (sent more than 2 hours ago)' do
        it 'redirects to /forgot_password without updating the password' do
          golfer.update_columns(password_reset_sent_at: 3.hours.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          expect(response).to redirect_to('/forgot_password')
        end
      end
    end

    context 'when welcome_token is true (admin-created golfer setting password for first time)' do
      before { golfer.update_columns(welcome_token: true) }

      context 'with a token sent 3 hours ago (expired by 2-hour rule, valid by 72-hour rule)' do
        it 'updates the password and redirects to /login' do
          golfer.update_columns(password_reset_sent_at: 3.hours.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          expect(response).to redirect_to('/login')
        end

        it 'resets welcome_token to false after successful password set' do
          golfer.update_columns(password_reset_sent_at: 3.hours.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          golfer.reload
          expect(golfer.welcome_token).to eq(false)
        end

        it 'clears the password_reset_token after success' do
          golfer.update_columns(password_reset_sent_at: 3.hours.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          golfer.reload
          expect(golfer.password_reset_token).to be_nil
        end
      end

      context 'with a token sent within 72 hours' do
        it 'updates the password and redirects to /login' do
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          expect(response).to redirect_to('/login')
        end

        it 'resets welcome_token to false after successful password set' do
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          golfer.reload
          expect(golfer.welcome_token).to eq(false)
        end
      end

      context 'with an expired token (sent more than 72 hours ago)' do
        it 'redirects to /forgot_password without updating the password' do
          golfer.update_columns(password_reset_sent_at: 73.hours.ago)
          raw_token = golfer.generate_password_reset_token!
          patch "/password_resets/#{raw_token}",
                params: { golfer: { password: 'newpassword1', password_confirmation: 'newpassword1' } }
          expect(response).to redirect_to('/forgot_password')
        end
      end
    end
  end
end
