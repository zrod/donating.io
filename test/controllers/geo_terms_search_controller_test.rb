require "test_helper"

class GeoTermsSearchControllerTest < ActionDispatch::IntegrationTest
  test "should allow unauthenticated access" do
    post "/geo_terms/search", params: { term: "toronto" }, as: :json
    assert_response :success
  end

  test "should return complete status when geo term exists" do
    geo_term = GeoTerm.create!(
      term: "toronto",
      parsed_response: [{ "display_name" => "Toronto, ON, Canada" }]
    )

    post "/geo_terms/search", params: { term: "TORONTO" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "complete", json_response["status"]
    assert_equal geo_term.parsed_response, json_response["results"]
    assert_equal geo_term.term, json_response["term"]
  end

  test "should return pending status when geo term does not exist" do
    assert_enqueued_with(job: GeoTerms::NominatimSearchJob) do
      post "/geo_terms/search", params: { term: "new york" }, as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "pending", json_response["status"]
  end

  test "should return error when term is missing" do
    post "/geo_terms/search", params: { term: "" }, as: :json
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_equal I18n.t("controllers.geo_terms_search.create.term_required"), json_response["error"]
  end

  test "should return error when term exceeds max length" do
    long_term = "a" * (GeoTerm::TERM_MAX_LENGTH + 1)
    post "/geo_terms/search", params: { term: long_term }, as: :json
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_equal I18n.t("controllers.geo_terms_search.create.term_too_long"), json_response["error"]
  end
end
