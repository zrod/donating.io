module Pagination
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 24
  MAX_PAGE_SIZE = 100

  included do
    helper_method :current_page, :page_size, :total_pages
  end

  private
    def paginate(collection:, filter_params:)
      total = collection.count
      metadata = pagination_metadata(total)
      offset = metadata[:offset]

      [records(collection, offset), metadata]
    end

    def current_page
      @current_page ||= [params[:page].to_i, 1].max
    end

    def page_size
      requested = params[:per_page].to_i
      @page_size ||= requested.positive? ? [requested, MAX_PAGE_SIZE].min : DEFAULT_PER_PAGE
    end

    def pagination_metadata(total)
      page_offset = current_page - 1
      pages       = [(total.to_f / page_size).ceil, 1].max
      offset      = current_page > pages ? page_size : page_offset * page_size

      {
        offset:,
        pages:,
        page: current_page,
        total:
      }
    end

    # @todo finish caching
    def records(collection, offset)
      # return collection.limit(page_size).offset(offset) if cache_key_prefix.blank?

      # cache_key_hash  = Digest::SHA1.hexdigest([page_size, offset, filter_params.to_json].join)
      # cache_key       = [cache_key_prefix, cache_key_hash].join("/")

      # ids = Rails.cache.fetch(cache_key, expires_in: cache_key_expiry) do
      collection.limit(page_size).offset(offset) # .pluck(:id)
      # end

      # collection.where(id: ids)
    end
end
