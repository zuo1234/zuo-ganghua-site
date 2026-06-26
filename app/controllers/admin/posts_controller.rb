module Admin
  class PostsController < BaseController
    before_action :set_post, only: [:show, :edit, :update, :destroy, :preview, :publish, :unpublish]

    def index
      @posts = Post.recent_first
    end

    def show
      redirect_to edit_admin_post_path(@post)
    end

    def new
      @post = Post.new(status: "draft")
    end

    def create
      @post = Post.new(post_params)
      normalize_commit_action

      if @post.save
        redirect_after_save("Post created.")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @post.assign_attributes(post_params)
      normalize_commit_action

      if @post.save
        redirect_after_save("Post updated.")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy!

      redirect_to admin_posts_path, notice: "Post deleted."
    end

    def preview
    end

    def publish
      @post.publish!

      redirect_to admin_posts_path, notice: "Post published."
    end

    def unpublish
      @post.unpublish!

      redirect_to admin_posts_path, notice: "Post moved back to draft."
    end

    private

    def set_post
      @post = Post.find_by!(slug: params[:slug])
    end

    def post_params
      params.require(:post).permit(:title, :slug, :excerpt, :body, :status, :published_at)
    end

    def normalize_commit_action
      case params[:commit_action]
      when "draft"
        @post.status = "draft"
      when "publish"
        @post.status = "published"
        @post.published_at ||= Time.current
      end
    end

    def redirect_after_save(message)
      if params[:commit_action] == "preview"
        redirect_to preview_admin_post_path(@post), notice: message
      else
        redirect_to edit_admin_post_path(@post), notice: message
      end
    end
  end
end
