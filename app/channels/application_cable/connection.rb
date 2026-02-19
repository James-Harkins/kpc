module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      golfer_id = env["rack.session"][:golfer_id]
      verified_user = Golfer.find_by(id: golfer_id) if golfer_id
      verified_user || reject_unauthorized_connection
    end
  end
end
