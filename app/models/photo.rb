class Photo < ApplicationRecord
  before_validation :normalize_slug

  validates :title, :slug, :image_url, presence: true
  validates :slug, uniqueness: true
  validates :slug, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  scope :published, -> { where(published: true).order(featured: :desc, taken_on: :desc, created_at: :desc) }
  scope :recent_first, -> { order(featured: :desc, taken_on: :desc, updated_at: :desc) }

  def to_param
    slug
  end

  private

  def normalize_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
    self.slug = slug.to_s.parameterize
  end
end
