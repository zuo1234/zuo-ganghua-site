class Post < ApplicationRecord
  STATUSES = %w[draft published].freeze

  before_validation :normalize_slug
  before_validation :clear_published_at, if: :draft?
  before_validation :set_published_at, if: :publishing_now?

  validates :title, :slug, :body, :status, presence: true
  validates :slug, uniqueness: true
  validates :slug, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  validates :status, inclusion: { in: STATUSES }

  scope :published, -> { where(status: "published").where.not(published_at: nil).order(published_at: :desc) }
  scope :recent_first, -> { order(Arel.sql("COALESCE(published_at, updated_at) DESC")) }

  def self.find_published!(slug)
    published.find_by!(slug: slug)
  end

  def draft?
    status == "draft"
  end

  def published?
    status == "published"
  end

  def publish!
    update!(status: "published", published_at: published_at || Time.current)
  end

  def unpublish!
    update!(status: "draft", published_at: nil)
  end

  def display_date
    published_at || updated_at || created_at
  end

  def to_param
    slug
  end

  private

  def normalize_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
    self.slug = slug.to_s.parameterize
  end

  def publishing_now?
    status_changed? && status == "published" && published_at.blank?
  end

  def clear_published_at
    self.published_at = nil
  end

  def set_published_at
    self.published_at = Time.current
  end
end
