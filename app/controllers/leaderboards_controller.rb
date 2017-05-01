class LeaderboardsController < ApplicationController
  before_action :query_options

  def show
    @lb = Boards.default_leaderboard
    @entries = entry_service.execute(query_options)
    render json: @entries
  end

  private

  def entry_service
    Boards::GetAllService.new
  end
end
