module Places
  class FilterPlacesService
    DEFAULT_ORDER_BY  = "desc"
    DEFAULT_SORT_BY   = "places.updated_at"
    DEFAULT_RADIUS = 40
    BOOLEAN_FILTERS = %i[
      pickup
      used_ok
      is_bin
      tax_receipt
    ].freeze

    NAMED_FILTERS = %i[
      category_ids
      charity_support
      near_me
      opening_hours
      keyword
    ].freeze

    FILTERS = [
      *NAMED_FILTERS,
      *BOOLEAN_FILTERS,
      :order,
      :sort_by
    ].freeze

    SORTABLE_COLUMNS = %i[
      name
      updated_at
      created_at
    ].freeze

    attr_reader :relation, :params, :page

    def initialize(params:, relation: Place.published, page: 1)
      @relation = relation
      validate_relation!

      @params = params
      @page = [page.to_i, 1].max
    end

    def call
      return relation if params.empty?

      sort_by, order = calc_sort_by_order

      scope = relation.includes(:categories, :place_hours)
      scope = apply_boolean_filters(scope)
      scope = apply_named_filters(scope)
      scope = filter_by_coordinates(scope) if filter_by_queried_latlng?

      scope.order(sort_by => order)
    end

    private
      def validate_relation!
        unless relation.is_a?(ActiveRecord::Relation) && relation.klass == Place
          raise ArgumentError, "Expected an ActiveRecord::Relation for Place, got #{relation.class}"
        end
      end

      def cast_to_boolean(value)
        ActiveRecord::Type::Boolean.new.cast(value)
      end

      def filter_by_queried_latlng?
        params[:lat].present? && params[:lng].present? && params[:near_me].blank?
      end

      def charity_support_enabled?
        cast_to_boolean(params[:charity_support])
      end

      def apply_boolean_filters(scope)
        apply_filters(scope, BOOLEAN_FILTERS) do |current_scope, filter|
          current_scope.where(filter => cast_to_boolean(params[filter]))
        end
      end

      def apply_named_filters(scope)
        apply_filters(scope, NAMED_FILTERS) do |current_scope, filter|
          send("with_#{filter}", current_scope)
        end
      end

      def apply_filters(scope, filters, &block)
        filters.select { |filter| filter_param_present?(filter) }.reduce(scope, &block)
      end

      def filter_param_present?(filter)
        params.key?(filter) && !params[filter].nil?
      end

      def with_category_ids(scope)
        category_ids = Array(params[:category_ids]).reject(&:blank?).uniq
        return scope if category_ids.empty?

        scope.joins(:categories).where(categories: { id: category_ids })
      end

      def with_charity_support(scope)
        if charity_support_enabled?
          scope.where.not(charity_support: [nil, ""])
        else
          scope.where(charity_support: [nil, ""])
        end
      end

      def with_near_me(scope)
        filter_by_coordinates(scope)
      end

      def with_opening_hours(scope)
        hours_params = params[:opening_hours]
        return scope unless hours_params.present?

        start_hour = hours_params[:start_time]
        end_hour = hours_params[:end_time]
        return scope unless start_hour.present? && end_hour.present?

        query = scope.joins(:place_hours)

        if hours_params[:day_of_week].present?
          query = query.where(place_hours: { day_of_week: hours_params[:day_of_week].to_i })
        end

        query = query.where(
          "place_hours.from_hour < :end_hour AND place_hours.to_hour > :start_hour",
          start_hour: start_hour.to_i,
          end_hour: end_hour.to_i
        )

        query.distinct
      end

      def with_keyword(scope)
        keyword = "%#{params[:keyword]}%"

        scope.where("places.name LIKE :q OR places.address LIKE :q OR places.city LIKE :q", q: keyword)
      end

      def filter_by_coordinates(scope)
        lat = params[:lat]
        lng = params[:lng]
        return scope unless lat.present? && lng.present?

        radius_km = params.fetch(:radius, DEFAULT_RADIUS).to_f
        Rails.logger.info("filter_by_coordinates: #{lat}, #{lng}, #{radius_km}")
        scope.near([lat.to_f, lng.to_f], radius_km, units: :km)
      end

      def calc_sort_by_order
        sort_by = DEFAULT_SORT_BY
        order   = DEFAULT_ORDER_BY

        if params[:order].present?
          req_order = params[:order].downcase
          order     = req_order if %w[asc desc].include?(req_order)
        end

        if params[:sort_by].present? && SORTABLE_COLUMNS.include?(params[:sort_by])
          sort_by = "places.#{params[:sort_by]}"
        end

        [sort_by, order]
      end
  end
end
