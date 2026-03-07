require "test_helper"

class PaginationUnitTest < ActiveSupport::TestCase
  class FakeController
    def self.helper_method(*); end

    include Pagination

    attr_accessor :params

    def initialize(params = {})
      @params = ActionController::Parameters.new(params)
    end

    def test_paginate(collection:, filter_params:, **options)
      paginate(collection:, filter_params:, **options)
    end

    def test_current_page = current_page
    def test_page_size = page_size

    def test_pagination_metadata(total)
      @cache_options = { prefix: nil, ttl: 1.hour, includes: [] }
      pagination_metadata(total)
    end
  end

  # current_page
  test "current_page defaults to 1 for invalid values" do
    assert_equal 1, FakeController.new({}).test_current_page
    assert_equal 1, FakeController.new(page: 0).test_current_page
    assert_equal 1, FakeController.new(page: -5).test_current_page
    assert_equal 1, FakeController.new(page: "invalid").test_current_page
  end

  test "current_page returns valid page" do
    assert_equal 3, FakeController.new(page: 3).test_current_page
    assert_equal 5, FakeController.new(page: "5").test_current_page
  end

  # page_size
  test "page_size defaults for invalid values" do
    assert_equal Pagination::DEFAULT_PER_PAGE, FakeController.new({}).test_page_size
    assert_equal Pagination::DEFAULT_PER_PAGE, FakeController.new(per_page: 0).test_page_size
    assert_equal Pagination::DEFAULT_PER_PAGE, FakeController.new(per_page: -10).test_page_size
  end

  test "page_size respects valid values and caps at max" do
    assert_equal 25, FakeController.new(per_page: 25).test_page_size
    assert_equal Pagination::MAX_PAGE_SIZE, FakeController.new(per_page: 500).test_page_size
  end

  # pagination_metadata
  test "pagination_metadata calculates correct values" do
    metadata = FakeController.new(page: 1, per_page: 10).test_pagination_metadata(50)

    assert_equal 0, metadata[:offset]
    assert_equal 5, metadata[:pages]
    assert_equal 1, metadata[:page]
    assert_equal 50, metadata[:total]
  end

  test "pagination_metadata calculates offset for middle pages" do
    metadata = FakeController.new(page: 3, per_page: 10).test_pagination_metadata(50)

    assert_equal 20, metadata[:offset]
    assert_equal 3, metadata[:page]
  end

  test "pagination_metadata clamps page when exceeds total" do
    metadata = FakeController.new(page: 999, per_page: 10).test_pagination_metadata(25)

    assert_equal 3, metadata[:pages]
    assert_equal 3, metadata[:page]
    assert_equal 20, metadata[:offset]
  end

  test "pagination_metadata returns 1 page for empty results" do
    metadata = FakeController.new(page: 1, per_page: 10).test_pagination_metadata(0)

    assert_equal 1, metadata[:pages]
    assert_equal 0, metadata[:total]
  end

  # paginate
  test "paginate returns records and metadata" do
    controller = FakeController.new(page: 1, per_page: 10)

    records, metadata = controller.test_paginate(
      collection: Place.published,
      filter_params: {}
    )

    assert_kind_of ActiveRecord::Relation, records
    assert_equal [:offset, :pages, :page, :total], metadata.keys
  end

  test "paginate with caching returns records" do
    controller = FakeController.new(page: 1, per_page: 10)

    records, metadata = controller.test_paginate(
      collection: Place.published,
      filter_params: { test: true },
      cache_key_prefix: "test_pagination",
      includes: [:categories]
    )

    assert_kind_of ActiveRecord::Relation, records
    assert metadata[:total] >= 0
  end
end

class PaginationIntegrationTest < ActionDispatch::IntegrationTest
  # page params
  test "handles invalid page params gracefully" do
    get places_url, params: { page: -5 }
    assert_response :success

    get places_url, params: { page: 999, per_page: 10 }
    assert_response :success
  end

  # caching
  test "cache keys differ by filter and page params" do
    get places_url, params: { is_bin: true }
    assert_response :success

    get places_url, params: { is_bin: false }
    assert_response :success

    get places_url, params: { page: 2, per_page: 1 }
    assert_response :success
  end

  # edge cases
  test "handles empty results" do
    get places_url, params: { keyword: "nonexistent_xyz_123" }
    assert_response :success
  end

  test "works with location filters" do
    get places_url, params: { lat: 43.65, lng: -79.38, radius: 50 }
    assert_response :success
  end

  # JSON
  test "returns paginated JSON response" do
    get places_url(format: :json), params: { page: 1, per_page: 2 }
    assert_response :success

    json = JSON.parse(response.body)
    assert json.key?("places")
    assert json.key?("total")
  end
end
