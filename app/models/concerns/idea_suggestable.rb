module IdeaSuggestable
  extend ActiveSupport::Concern

  class_methods do
    def generate_from_trends!(limit: 8)
      keywords = CreatorVideo.top_keywords(limit: 20)
      videos = CreatorVideo.high_velocity(limit: 25)
      return 0 if keywords.empty? || videos.empty?

      created = 0
      limit.times do |i|
        seed_video = videos[i % videos.length]
        kw1 = keywords[i % keywords.length]&.first
        kw2 = keywords[(i + 3) % keywords.length]&.first
        next if kw1.blank?

        title = format_title(seed_video: seed_video, kw1: kw1, kw2: kw2)
        next if exists?(title: title)

        score = [(seed_video.view_count.to_i / 10_000), 95].min + (kw2.present? ? 5 : 0)

        create!(
          title: title,
          angle: "Trend-driven: combine '#{kw1}'#{" + '#{kw2}'" if kw2.present?} with your builder/webdev perspective.",
          status: "backlog",
          score: score,
          notes: "Source video: #{seed_video.title}",
          creator_channel: seed_video.creator_channel,
          creator_video: seed_video
        )
        created += 1
      end

      created
    end

    def format_title(seed_video:, kw1:, kw2:)
      templates = [
        "I built a #{kw1} project no one should actually try",
        "Can Ruby + #{kw1} control this real-world build?",
        "I turned #{kw1} into a ridiculous maker challenge",
        "From web dev to hardware: shipping #{kw1} with #{kw2 || "code"}"
      ]
      templates.sample
    end
  end
end
