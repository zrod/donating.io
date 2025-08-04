class Category < ApplicationRecord
  has_many :categories_places, dependent: :destroy
  has_many :places, through: :categories_places

  validates :name, presence: true, length: { minimum: 4 }
  validates :slug, uniqueness: true

  before_save { self.slug = name.parameterize }

  scope :by_name, -> { order(:name) }
end
