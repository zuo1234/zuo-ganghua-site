module Admin
  class UploadsController < BaseController
    MAX_IMAGE_SIZE = 5.megabytes

    def create
      image = params[:image]

      unless image.respond_to?(:content_type)
        render json: { error: "请选择要上传的图片。" }, status: :unprocessable_entity
        return
      end

      unless image.content_type.to_s.start_with?("image/")
        render json: { error: "只能上传图片文件。" }, status: :unprocessable_entity
        return
      end

      if image.size > MAX_IMAGE_SIZE
        render json: { error: "图片不能超过 5MB。" }, status: :unprocessable_entity
        return
      end

      blob = ActiveStorage::Blob.create_and_upload!(
        io: image.tempfile,
        filename: image.original_filename,
        content_type: image.content_type
      )

      render json: {
        url: rails_blob_path(blob, only_path: true),
        filename: blob.filename.to_s,
        alt: File.basename(blob.filename.to_s, ".*")
      }
    end
  end
end
