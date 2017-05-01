module Boards
  class UpdateService < Boards::Base
    def execute(entry_params)
      name = entry_params[:name]
      score = entry_params[:score].to_i
      member = leaderboard.score_and_rank_for(name)
      if member[:score].nil? || member[:score] < score
        leaderboard.rank_member(name, score)
      end
      member[:page] = leaderboard.page_for(name, leaderboard.page_size)
      member
    end
  end
end
