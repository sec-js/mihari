# frozen_string_literal: true

require "base64"

module Mihari
  module Clients
    #
    # hunter.how API client
    #
    class HunterHow < Base
      PAGE_SIZE = 100

      # @return [String]
      attr_reader :api_key

      #
      # @param [String] base_url
      # @param [String, nil] api_key
      # @param [Hash] headers
      # @param [Integer] pagination_interval
      # @param [Integer, nil] timeout
      #
      def initialize(
        base_url = "https://api.hunter.how",
        api_key:,
        headers: {},
        pagination_interval: Mihari.config.pagination_interval,
        timeout: nil
      )
        raise(ArgumentError, "api_key is required") unless api_key

        super(base_url, headers:, pagination_interval:, timeout:)

        @api_key = api_key
      end

      #
      # @param [String] query String used to query our data
      # @param [Integer] page Default 1, Maximum: 500
      # @param [Integer] page_size Default 100, Maximum: 100
      # @param [String] start_time
      # @param [String] end_time
      #
      # @return [Mihari::Structs::HunterHow::Response]
      #
      def search(query, start_time:, end_time:, page: 1, page_size: PAGE_SIZE)
        params = {
          query: Base64.urlsafe_encode64(query),
          page:,
          page_size:,
          start_time:,
          end_time:,
          "api-key": api_key
        }.compact
        Structs::HunterHow::Response.from_dynamic! get_json("/search", params:)
      end

      #
      # @param [String] query String used to query our data
      # @param [Integer] page_size Default 100, Maximum: 100
      # @param [Integer] pagination_limit
      # @param [String] start_time
      # @param [String] end_time
      #
      # @return [Enumerable<Mihari::Structs::HunterHow::Response>]
      #
      def search_with_pagination(
        query,
        start_time:,
        end_time:,
        page_size: PAGE_SIZE,
        pagination_limit: Mihari.config.pagination_limit
      )
        Enumerator.new do |y|
          (1..pagination_limit).each do |page|
            res = search(
              query,
              start_time:,
              end_time:,
              page:,
              page_size:
            )

            y.yield res

            break if res.data.list.length < page_size

            sleep_pagination_interval
          end
        end
      end
    end
  end
end
