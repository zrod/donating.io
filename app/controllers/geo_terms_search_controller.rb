class GeoTermsSearchController < ApplicationController
  POLL_INTERVAL_MS = 2000
  MAX_RETRIES = 10

  allow_unauthenticated_access

  rate_limit to: MAX_RETRIES,
             within: 1.minute,
             only: :create,
             with: -> { render json: { error: I18n.t("controllers.geo_terms_search.create.too_many_requests") }, status: :too_many_requests }

  def create
    term = create_params[:term]
    return render json: { error: I18n.t("controllers.geo_terms_search.create.term_required") }, status: :bad_request unless term.present?
    return render json: { error: I18n.t("controllers.geo_terms_search.create.term_too_long") }, status: :bad_request if term.length > GeoTerm::TERM_MAX_LENGTH

    result = GeoTerms::TermLookupService.new(term:).call
    status, json_response = format_search_response(result, term)
    render json: json_response, status:
  rescue GeoTerms::TermLookupService::BlankSearchTermError
    render json: { error: I18n.t("controllers.geo_terms_search.create.term_required") }, status: :bad_request
  end

  private
    def format_search_response(result, term)
      case result
      when GeoTerm
        [ :ok, { status: "complete", results: result.parsed_response, term: result.term } ]
      when :failed
        [ :service_unavailable, { status: "failed", results: [], term: } ]
      else
        [ :ok, { status: "pending", results: [], term: } ]
      end
    end

    def create_params
      params.permit(:term)
    end
end
