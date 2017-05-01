module Boards
  class GetAllService < Boards::Base
    def execute(options = {})
      {
        members: leaderboard.leaders(page(options).to_i, page_size: page_size(options)),
        total_members: leaderboard.total_members,
        total_pages: leaderboard.total_pages
      }
    end

    private

    def page(options)
      options[:page].to_i || 1
    end

    def page_size(options)
      options[:page_size].to_i || 10
    end
  end
end
