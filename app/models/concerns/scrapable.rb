require "net/http"
require "json"

module Scrapable
  extend ActiveSupport::Concern

  class ScrapingError < StandardError; end

  class_methods do
    def fetch_json(url, headers: {})
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "NewsAggregator/1.0 (Rails)"
      headers.each { |key, value| request[key] = value }

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise ScrapingError, "HTTP #{response.code}: #{response.message}"
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise ScrapingError, "Invalid JSON response: #{e.message}"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise ScrapingError, "Request timeout: #{e.message}"
    rescue => e
      raise ScrapingError, "Request failed: #{e.message}"
    end

    def upsert_article(attributes)
      article = find_or_initialize_by(
        source: attributes[:source],
        external_id: attributes[:external_id]
      )

      article.assign_attributes(attributes)
      article.scraped_at = Time.current
      article.save!
      article
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to save article: #{e.message}")
      nil
    end
  end
end
