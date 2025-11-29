require "test_helper"

class GeoTermsSearchControllerTest < ActionDispatch::IntegrationTest
  test "should allow unauthenticated access" do
    with_no_failed_search_jobs do
      post "/geo_terms/search", params: { term: "toronto" }, as: :json
      assert_response :success
    end
  end

  test "should return error when term is missing" do
    post "/geo_terms/search", params: { term: "" }, as: :json
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_equal I18n.t("controllers.geo_terms_search.create.term_required"), json_response["error"]
  end

  test "should return error when term is nil" do
    post "/geo_terms/search", params: { term: nil }, as: :json
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
    with_no_failed_search_jobs do
      assert_enqueued_with(job: GeoTerms::NominatimSearchJob) do
        post "/geo_terms/search", params: { term: "new york" }, as: :json
      end

      assert_response :success
      json_response = JSON.parse(response.body)
      assert_equal "pending", json_response["status"]
    end
  end

  test "should return failed status when search job has failed" do
    term = "failed search"
    normalized_term = GeoTerm.normalize_term(term)

    with_failed_search_job do
      post "/geo_terms/search", params: { term: }, as: :json

      assert_response :service_unavailable
      json_response = JSON.parse(response.body)
      assert_equal "failed", json_response["status"]
      assert_equal [], json_response["results"]
      assert_equal normalized_term, json_response["term"]
    end
  end
end
