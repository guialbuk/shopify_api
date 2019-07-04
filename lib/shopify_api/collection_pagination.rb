module ShopifyAPI
  module CollectionPagination

    def next_page?
      next_page_info.present?
    end

    def previous_page?
      previous_page_info.present?
    end

    def fetch_next_page
      fetch_page(next_page_info)
    end

    def fetch_previous_page
      fetch_page(previous_page_info)
    end

    private

    AVAILABLE_IN_VERSION = ShopifyAPI::ApiVersion::Unstable.new

    def fetch_page(page_info)
      return [] unless page_info

      resource_class.where(original_params.merge(page_info: page_info))
    end

    def previous_page_info
      @previous_page_info ||= extract_page_info(pagination_link_headers.previous_link)
    end

    def next_page_info
      @next_page_info ||= extract_page_info(pagination_link_headers.next_link)
    end

    def extract_page_info(link_header)
      raise NotImplementedError unless ShopifyAPI::Base.api_version >= AVAILABLE_IN_VERSION

      return nil unless link_header.present?

      CGI.parse(link_header.url.query).dig("page_info", 0)
    end

    def pagination_link_headers
      @pagination_link_headers ||= ShopifyAPI::PaginationLinkHeaders.new(
        ShopifyAPI::Base.connection.response["Link"]
      )
    end
  end
end
