class RostersController < ApplicationController
  before_action :require_admin

  def index
    @admin_golfers = Golfer.where(role: :admin).order(:last_name, :first_name)
    @default_golfers = Golfer.where(role: :default).order(:last_name, :first_name)
  end
end
