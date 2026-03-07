# frozen_string_literal: true

class CategoriesPlace < ApplicationRecord
  belongs_to :place
  belongs_to :category

  validates :place, :category, presence: true
end
