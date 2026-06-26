module PhotosHelper
  def photo_meta(photo)
    [photo.location.presence, photo.taken_on&.strftime("%b %Y")].compact.join(" · ")
  end
end
