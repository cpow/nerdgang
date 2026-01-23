module RedditScrapable
  extend ActiveSupport::Concern
  include Scrapable

  SUBREDDITS = %w[
    programming
    webdev
    javascript
    linux
    commandline
    selfhosted
    devops
    sysadmin
    opensource
  ].freeze

  class_methods do
    def scrape_reddit(subreddits: SUBREDDITS, limit: 25)
      articles = []

      subreddits.each do |subreddit|
        articles.concat(scrape_subreddit(subreddit, limit: limit))
      rescue Scrapable::ScrapingError => e
        Rails.logger.error("Failed to scrape r/#{subreddit}: #{e.message}")
      end

      articles
    end

    def scrape_subreddit(subreddit, limit: 25)
      url = "https://www.reddit.com/r/#{subreddit}/hot.json?limit=#{limit}"
      data = fetch_json(url)

      posts = data.dig("data", "children") || []

      posts.filter_map do |post|
        post_data = post["data"]

        next if post_data["is_self"] || post_data["stickied"]

        upsert_article(
          source: "reddit",
          source_name: subreddit,
          external_id: post_data["id"],
          title: post_data["title"],
          url: post_data["url"],
          author: post_data["author"],
          score: post_data["score"],
          comments_count: post_data["num_comments"],
          published_at: Time.zone.at(post_data["created_utc"])
        )
      end
    end
  end
end
