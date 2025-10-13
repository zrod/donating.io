module PaginationHelper
  def pagination_links(current_page, total_pages, path, params = {}, turbo_frame: nil)
    return "" if total_pages <= 1

    turbo_data = turbo_frame ? { turbo_frame: turbo_frame, turbo_action: "advance" } : {}

    content_tag :div, class: "join" do
      links = []

      if current_page > 1
        links << link_to("«", path + "?" + build_query_string(params.merge(page: current_page - 1)), class: "join-item btn", data: turbo_data)
      else
        links << content_tag(:span, "«", class: "join-item btn btn-disabled")
      end

      page_range(current_page, total_pages).each do |page|
        if page == "..."
          links << content_tag(:span, "...", class: "join-item btn btn-disabled")
        elsif page == current_page
          links << content_tag(:span, page, class: "join-item btn btn-active")
        else
          links << link_to(page, path + "?" + build_query_string(params.merge(page:)), class: "join-item btn", data: turbo_data)
        end
      end

      if current_page < total_pages
        links << link_to("»", path + "?" + build_query_string(params.merge(page: current_page + 1)), class: "join-item btn", data: turbo_data)
      else
        links << content_tag(:span, "»", class: "join-item btn btn-disabled")
      end

      safe_join(links)
    end
  end

  private
    def page_range(current_page, total_pages)
      return (1..total_pages).to_a if total_pages <= 7

      if current_page <= 4
        (1..5).to_a + ["..."] + [total_pages]
      elsif current_page >= total_pages - 3
        [1] + ["..."] + ((total_pages - 4)..total_pages).to_a
      else
        [1] + ["..."] + ((current_page - 1)..(current_page + 1)).to_a + ["..."] + [total_pages]
      end
    end

    def build_query_string(params)
      params.compact.reject { |k, v| v.blank? }.to_query
    end
end
