module Pagination
  extend ActiveSupport::Concern

  CACHE_TTL = 1.hour
  DEFAULT_PER_PAGE = 16
  MAX_PAGE_SIZE = 60

  included do
    helper_method :current_page, :page_size, :total_pages
  end

  private
    def paginate(collection:, filter_params:, **options)
      @cache_options = {
        prefix: options[:cache_key_prefix],
        ttl: options.fetch(:cache_ttl, CACHE_TTL),
        includes: options.fetch(:includes, [])
      }

      total = cache_fetch(filter_params) { collection.except(:select).count }
      metadata = pagination_metadata(total)
      records = paginated_records(collection, filter_params, metadata[:offset])

      [records, metadata]
    end

    def current_page
      @current_page ||= [params[:page].to_i, 1].max
    end

    def page_size
      requested = params[:per_page].to_i
      @page_size ||= requested.positive? ? [requested, MAX_PAGE_SIZE].min : DEFAULT_PER_PAGE
    end

    def total_pages
      @total_pages
    end

    def pagination_metadata(total)
      pages = [(total.to_f / page_size).ceil, 1].max
      resolved_page = [current_page, pages].min

      @total_pages = pages

      {
        offset: (resolved_page - 1) * page_size,
        pages:,
        page: resolved_page,
        total:
      }
    end

    def paginated_records(collection, filter_params, offset)
      return collection.limit(page_size).offset(offset) unless @cache_options[:prefix]

      ids = cache_fetch(filter_params, page_size, offset) do
        collection.limit(page_size).offset(offset).load.map(&:id)
      end

      return collection.none if ids.empty?

      collection.klass
        .includes(@cache_options[:includes])
        .where(id: ids)
        .in_order_of(:id, ids)
    end

    def cache_fetch(*key_parts, &block)
      return yield unless @cache_options[:prefix]

      key_hash = Digest::SHA1.hexdigest(key_parts.map(&:to_json).join("/"))
      Rails.cache.fetch("#{@cache_options[:prefix]}/#{key_hash}", expires_in: @cache_options[:ttl], &block)
    end
end
