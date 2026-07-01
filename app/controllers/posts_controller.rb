class PostsController < ApplicationController
  def index
    @posts = Post.published
    @selected_tag = params[:tag].presence if Post.tags.key?(params[:tag])
    @posts = @posts.with_tag(@selected_tag) if @selected_tag
  end

  def show
    @post = Post.find_published!(params[:slug])
  end
end
