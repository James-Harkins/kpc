require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let!(:golfer) do
    Golfer.create!(first_name: 'Tony', last_name: 'Soprano', nickname: 'T',
                   email: 't@badabing.com', password: 'test1234',
                   password_confirmation: 'test1234', t_shirt_size: :m)
  end

  describe 'GET /login' do
    it 'returns a successful response' do
      get '/login'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'redirects to the dashboard' do
        post '/login', params: { email: 't@badabing.com', password: 'test1234' }
        expect(response).to redirect_to('/dashboard')
      end
    end

    context 'with an incorrect password' do
      it 'redirects back to login' do
        post '/login', params: { email: 't@badabing.com', password: 'wrongpass' }
        expect(response).to redirect_to('/login')
      end
    end

    context 'with an unknown email' do
      it 'redirects to register' do
        post '/login', params: { email: 'nobody@nowhere.com', password: 'test1234' }
        expect(response).to redirect_to('/register')
      end
    end
  end

  describe 'DELETE /logout' do
    it 'redirects to root' do
      delete '/logout'
      expect(response).to redirect_to('/')
    end
  end
end
