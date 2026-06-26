class PagesController < ApplicationController
  def home
    @recent_posts = Post.published.limit(4)
  end

  def games
    @initial_game = "path"
  end

  def rubordle
    @initial_game = "rubordle"

    render :games
  end
end
