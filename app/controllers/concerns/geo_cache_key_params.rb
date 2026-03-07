module GeoCacheKeyParams
  extend ActiveSupport::Concern

  private
    def cache_key_params(filter_params)
      params = filter_params.to_h.deep_dup

      %w[lat lng].each do |key|
        params[key] = params[key].to_f.round(2) if params[key].present?
      end

      params
    end
end
