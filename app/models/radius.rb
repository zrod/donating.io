# frozen_string_literal: true

class Radius
  DEFAULT_KM_RADIUS = 40
  DEFAULT_MI_RADIUS = 50
  DEFAULT_DISTANCE_UNIT = :km
  KM_LIST = [1, 5, 10, 20, 40, 60, 80, 100].freeze
  MI_LIST = [1, 5, 10, 25, 50, 75, 100].freeze

  def self.list(distance_unit = DEFAULT_DISTANCE_UNIT)
    return KM_LIST if distance_unit == :km

    MI_LIST
  end

  def self.default_radius(distance_unit = DEFAULT_DISTANCE_UNIT)
    return DEFAULT_KM_RADIUS if distance_unit == :km

    DEFAULT_MI_RADIUS
  end
end
