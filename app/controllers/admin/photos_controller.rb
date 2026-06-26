module Admin
  class PhotosController < BaseController
    before_action :set_photo, only: [:show, :edit, :update, :destroy]

    def index
      @photos = Photo.recent_first
    end

    def show
      redirect_to edit_admin_photo_path(@photo)
    end

    def new
      @photo = Photo.new(published: true)
    end

    def create
      @photo = Photo.new(photo_params)

      if @photo.save
        redirect_to edit_admin_photo_path(@photo), notice: "Photo created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @photo.update(photo_params)
        redirect_to edit_admin_photo_path(@photo), notice: "Photo updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @photo.destroy!

      redirect_to admin_photos_path, notice: "Photo deleted."
    end

    private

    def set_photo
      @photo = Photo.find_by!(slug: params[:slug])
    end

    def photo_params
      params.require(:photo).permit(:title, :slug, :description, :image_url, :location, :taken_on, :featured, :published)
    end
  end
end
