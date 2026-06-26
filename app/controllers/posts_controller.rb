class PostsController < ApplicationController
  def index
    @posts = Post.published
  end

  def show
    @post = Post.find_published!(params[:slug])
  end
end
