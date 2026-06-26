class PhotosController < ApplicationController
  def index
    @photos = Photo.published
  end

  def show
    @photo = Photo.published.find_by!(slug: params[:slug])
  end
end
