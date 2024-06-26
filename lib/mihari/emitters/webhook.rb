# frozen_string_literal: true

module Mihari
  module Emitters
    class Webhook < Base
      # @return [Addressable::URI, nil]
      attr_reader :url

      # @return [Hash]
      attr_reader :headers

      # @return [String]
      attr_reader :method

      # @return [String]
      attr_reader :template

      # @return [Array<Mihari::Models::Artifact>]
      attr_accessor :artifacts

      DEFAULT_TEMPLATE = %{
          json.rule do
          json.id rule.id
          json.title rule.title
          json.description rule.description
        end

        json.artifacts artifacts.map(&:data)

        json.tags rule.tags.map(&:name)
      }

      #
      # @param [Mihari::Rule] rule
      # @param [Hash, nil] options
      # @param [Hash, nil] params
      #
      def initialize(rule:, options: nil, **params)
        super(rule:, options:)

        @url = Addressable::URI.parse(params[:url])
        @headers = params[:headers] || {}
        @method = params[:method] || "POST"
        @template = params[:template] || DEFAULT_TEMPLATE

        @artifacts = []
      end

      #
      # @return [Boolean]
      #
      def configured?
        return false if url.nil?

        %w[http https].include? url.scheme.downcase
      end

      #
      # @return [String]
      #
      def target
        URI(url).host || "N/A"
      end

      #
      # @param [Array<Mihari::Models::Artifact>] artifacts
      #
      def call(artifacts)
        return if artifacts.empty?

        @artifacts = artifacts

        # returns body to prevent Parallel issue (Parallel fails to handle HTTP:Response object)
        case method
        when "GET"
          http.get(url).body.to_s
        when "POST"
          http.post(url, json:).body.to_s
        end
      end

      private

      def http
        HTTP::Factory.build headers:, timeout:
      end

      #
      # Render template
      #
      # @return [String]
      #
      def render
        Services::JbuilderRenderer.call(template, {rule:, artifacts:})
      end

      #
      # @return [Hash]
      #
      def json
        JSON.parse render
      end
    end
  end
end
