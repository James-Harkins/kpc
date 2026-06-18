require 'rails_helper'

RSpec.describe 'Golfers', type: :request do
  def make_golfer(email:, role: :default)
    Golfer.create!(
      first_name: 'Tony', last_name: 'Soprano', nickname: 'Tony',
      email: email, password: 'test1234', password_confirmation: 'test1234',
      role: role, t_shirt_size: :m
    )
  end

  def log_in_as(golfer)
    post '/login', params: { email: golfer.email, password: 'test1234' }
  end

  describe 'GET /admin/golfer/new' do
    context 'when not logged in' do
      it 'redirects to /login' do
        get '/admin/golfer/new'
        expect(response).to redirect_to('/login')
      end
    end

    context 'when logged in as a non-site-admin golfer' do
      around do |example|
        orig = ENV['SITE_ADMIN_EMAIL']
        ENV['SITE_ADMIN_EMAIL'] = 'siteadmin@kpc.com'
        example.run
        ENV['SITE_ADMIN_EMAIL'] = orig
      end

      before do
        @golfer = make_golfer(email: 'regular@kpc.com')
        log_in_as(@golfer)
      end

      it 'redirects to /dashboard' do
        get '/admin/golfer/new'
        expect(response).to redirect_to('/dashboard')
      end
    end

    context 'when logged in as site admin' do
      around do |example|
        orig = ENV['SITE_ADMIN_EMAIL']
        ENV['SITE_ADMIN_EMAIL'] = 'siteadmin@kpc.com'
        example.run
        ENV['SITE_ADMIN_EMAIL'] = orig
      end

      before do
        @site_admin = make_golfer(email: 'siteadmin@kpc.com', role: :admin)
        log_in_as(@site_admin)
      end

      it 'returns a successful response' do
        get '/admin/golfer/new'
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /admin/golfer' do
    let(:valid_params) do
      {
        first_name: 'Bobby', last_name: 'Bacalieri', nickname: 'Bobby',
        email: 'bobby@badabing.com', t_shirt_size: :m
      }
    end

    context 'when not logged in' do
      it 'redirects to /login' do
        post '/admin/golfer', params: valid_params
        expect(response).to redirect_to('/login')
      end

      it 'does not create a new golfer' do
        expect {
          post '/admin/golfer', params: valid_params
        }.not_to change(Golfer, :count)
      end
    end

    context 'when logged in as a non-site-admin golfer' do
      around do |example|
        orig = ENV['SITE_ADMIN_EMAIL']
        ENV['SITE_ADMIN_EMAIL'] = 'siteadmin@kpc.com'
        example.run
        ENV['SITE_ADMIN_EMAIL'] = orig
      end

      before do
        @golfer = make_golfer(email: 'regular@kpc.com')
        log_in_as(@golfer)
      end

      it 'redirects to /dashboard' do
        post '/admin/golfer', params: valid_params
        expect(response).to redirect_to('/dashboard')
      end

      it 'does not create a new golfer' do
        expect {
          post '/admin/golfer', params: valid_params
        }.not_to change(Golfer, :count)
      end
    end

    context 'when logged in as site admin' do
      around do |example|
        orig = ENV['SITE_ADMIN_EMAIL']
        ENV['SITE_ADMIN_EMAIL'] = 'siteadmin@kpc.com'
        example.run
        ENV['SITE_ADMIN_EMAIL'] = orig
      end

      before do
        @site_admin = make_golfer(email: 'siteadmin@kpc.com', role: :admin)
        log_in_as(@site_admin)
        ActionMailer::Base.deliveries.clear
      end

      context 'with valid params' do
        it 'creates a new golfer' do
          expect {
            post '/admin/golfer', params: valid_params
          }.to change(Golfer, :count).by(1)
        end

        it 'creates the golfer with welcome_token set to true' do
          post '/admin/golfer', params: valid_params
          new_golfer = Golfer.find_by(email: 'bobby@badabing.com')
          expect(new_golfer.welcome_token).to eq(true)
        end

        it 'creates the golfer with role default' do
          post '/admin/golfer', params: valid_params
          new_golfer = Golfer.find_by(email: 'bobby@badabing.com')
          expect(new_golfer.role).to eq('default')
        end

        it 'sends a welcome email to the new golfer' do
          post '/admin/golfer', params: valid_params
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.last.to).to include('bobby@badabing.com')
        end

        it 'sends a welcome email with subject "Welcome to Kitchen Pass Classic"' do
          post '/admin/golfer', params: valid_params
          expect(ActionMailer::Base.deliveries.last.subject).to eq('Welcome to Kitchen Pass Classic')
        end

        it 'redirects to /dashboard' do
          post '/admin/golfer', params: valid_params
          expect(response).to redirect_to('/dashboard')
        end

        it 'sets a flash notice' do
          post '/admin/golfer', params: valid_params
          expect(flash[:notice]).to be_present
        end
      end

      context 'with invalid params (missing email)' do
        let(:invalid_params) do
          { first_name: 'Bobby', last_name: 'Bacalieri', nickname: 'Bobby', t_shirt_size: :m }
        end

        it 'does not create a new golfer' do
          expect {
            post '/admin/golfer', params: invalid_params
          }.not_to change(Golfer, :count)
        end

        it 'does not send a welcome email' do
          post '/admin/golfer', params: invalid_params
          expect(ActionMailer::Base.deliveries).to be_empty
        end

        it 'redirects to /admin/golfer/new' do
          post '/admin/golfer', params: invalid_params
          expect(response).to redirect_to('/admin/golfer/new')
        end

        it 'sets a flash error' do
          post '/admin/golfer', params: invalid_params
          expect(flash[:error]).to be_present
        end
      end
    end
  end
end
