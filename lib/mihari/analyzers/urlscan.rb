# frozen_string_literal: true

require "urlscan"

module Mihari
  module Analyzers
    class Urlscan < Base
      attr_reader :api
      attr_reader :title
      attr_reader :description
      attr_reader :query
      attr_reader :tags
      attr_reader :target_type

      def initialize(query, title: nil, description: nil, tags: [], target_type: "url")
        super()

        @api = ::UrlScan::API.new
        @query = query
        @title = title || "urlscan lookup"
        @description = description || "query = #{query}"
        @tags = tags
        @target_type = target_type

        raise ArgumentError, "type should be url, domain or ip." unless valid_target_type?
      end

      def artifacts
        result = search
        return [] unless result

        results = result.dig("results") || []
        results.map do |match|
          match.dig "page", target_type
        end.compact.uniq
      end

      private

      def search
        api.search(query)
      rescue ::UrlScan::ResponseError => _e
        nil
      end

      def valid_target_type?
        %w(url domain ip).include? target_type
      end
    end
  end
end