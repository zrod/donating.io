class GeoTermsSearchController < ApplicationController
  POLL_INTERVAL_MS = 2000
  MAX_RETRIES = 10

  allow_unauthenticated_access

  rate_limit to: MAX_RETRIES,
             within: 1.minute,
             only: :create,
             with: -> { render json: { error: I18n.t("controllers.geo_terms_search.create.too_many_requests") }, status: :too_many_requests }

  def create
    term = create_params[:term]&.strip
    return render json: { error: I18n.t("controllers.geo_terms_search.create.term_required") }, status: :bad_request unless term.present?
    return render json: { error: I18n.t("controllers.geo_terms_search.create.term_too_long") }, status: :bad_request if term.length > GeoTerm::TERM_MAX_LENGTH

    normalized_term = GeoTerm.normalize_term(term)
    geo_term = GeoTerm.find_by(term: normalized_term)

    if geo_term
      render json: {
        status: "complete",
        results: geo_term.parsed_response,
        term: geo_term.term
      }
    else
      GeoTerms::TermLookupService.new(term:).call
      render json: { status: "pending" }
    end
  end

  private
    def create_params
      params.permit(:term)
    end
end
