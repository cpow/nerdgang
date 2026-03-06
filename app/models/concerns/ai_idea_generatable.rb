module AiIdeaGeneratable
  extend ActiveSupport::Concern

  class_methods do
    def generate_with_ai!(limit: 8)
      return 0 unless ai_available?

      channel = CreatorChannel.find_by(handle: "@typecraft_dev")
      return 0 unless channel

      keywords = CreatorVideo.top_keywords(limit: 15)
      videos = CreatorVideo.high_velocity(limit: 20)
      return 0 if keywords.empty? || videos.empty?

      prompt = build_idea_prompt(
        keywords: keywords,
        videos: videos,
        niche_tags: channel.niche_tags_array,
        limit: limit
      )

      response = call_claude_api(prompt)
      return 0 if response.blank?

      ideas = parse_ai_response(response)
      create_ideas_from_ai(ideas, channel)
    end

    def ai_available?
      ENV["ANTHROPIC_API_KEY"].present?
    end

    private

    def build_idea_prompt(keywords:, videos:, niche_tags:, limit:)
      keyword_list = keywords.map { |kw, count| "#{kw} (#{count} mentions)" }.join(", ")
      video_examples = videos.first(10).map { |v| "- #{v.title} (#{v.view_count} views)" }.join("\n")
      niche_str = niche_tags.join(", ")

      <<~PROMPT
        #{system_prompt}

        CURRENT TRENDING KEYWORDS IN THE SPACE: #{keyword_list}

        HIGH-PERFORMING VIDEOS FROM SIMILAR CREATORS:
        #{video_examples}

        MY CHANNEL'S NICHE FOCUS: #{niche_str}

        Generate #{limit} video ideas. Return ONLY a JSON array with objects containing:
        - "title": clickbait-y but honest title (under 60 chars, use caps strategically)
        - "angle": 2-3 sentences explaining the unique twist and why it's compelling
        - "hook": the first 10 seconds - what do you say/show to stop the scroll
        - "thumbnail_concept": describe the thumbnail (expression, text overlay, visual)
        - "key_points": 3-5 bullet points of what the video covers
        - "hardware_components": comma-separated list of hardware needed
        - "difficulty": "beginner", "intermediate", or "advanced"
        - "score": viral potential 1-100 (be harsh, 80+ should be rare)

        Example:
        [{"title": "I Put Linux on a $3 Chip and It Actually Works", "angle": "Take the cheapest microcontroller on AliExpress and get a full Linux environment running. The absurdity of running neovim on hardware that costs less than a coffee.", "hook": "This chip costs three dollars. By the end of this video, it's going to be running Arch Linux. And yes, I use Arch btw.", "thumbnail_concept": "Me looking shocked, holding tiny chip between fingers. Text: '$3 LINUX??'. Red circle around the chip.", "key_points": "- Sourcing ultra-cheap chips\\n- What 'Linux-capable' actually means\\n- Kernel compilation for weird hardware\\n- Actually using it (sort of)\\n- When this makes sense vs RPi", "hardware_components": "CH32V003, USB-TTL adapter, breadboard, jumper wires", "difficulty": "advanced", "score": 78}]

        Return only the JSON array, no other text.
      PROMPT
    end

    def system_prompt
      <<~SYSTEM
        You are a video idea generator for a developer/maker YouTube channel that makes UNHINGED hardware projects.

        The channel philosophy:
        - We don't do boring tutorials. We do "what if?" experiments that seem slightly insane.
        - Hardware is the star: Raspberry Pi, Arduino, ESP32, random microcontrollers, weird sensors, mechanical keyboards, custom PCBs
        - We combine unexpected things: AI + hardware, retro + modern, serious tools + absurd applications
        - Linux/terminal/neovim/command-line aesthetic - we're not afraid of the terminal
        - Self-hosted, privacy-conscious, DIY ethos
        - "I spent 40 hours on something stupid so you don't have to" energy

        Title style:
        - First-person, casual ("I Built...", "I Mass...", "Why I Switched...")
        - Specific and concrete, not vague
        - Creates curiosity gap without being pure clickbait
        - Examples of good titles: "I Mass a Kubernetes Cluster Out of Old Phones", "This $6 Microcontroller Runs Doom", "I Replaced My Entire Smart Home With a Raspberry Pi"

        Ideas should be:
        - UNIQUE - not "how to set up a Raspberry Pi" but "I turned a Raspberry Pi into a cursed gaming console"
        - VISUAL - hardware projects photograph/film well
        - ACHIEVABLE - crazy but actually buildable
        - EDUCATIONAL - viewers learn something even if the project is silly
        - SHAREABLE - people want to send this to their nerd friends
      SYSTEM
    end

    def call_claude_api(prompt)
      client = Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])

      response = client.messages.create(
        model: "claude-sonnet-4-20250514",
        max_tokens: 2048,
        messages: [{role: "user", content: prompt}]
      )

      response.content.first.text
    rescue => e
      Rails.logger.error("AI idea generation failed: #{e.message}")
      nil
    end

    def parse_ai_response(response)
      json_match = response.match(/\[[\s\S]*\]/)
      return [] unless json_match

      JSON.parse(json_match[0])
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse AI response: #{e.message}")
      []
    end

    def create_ideas_from_ai(ideas, channel)
      created = 0

      ideas.each do |idea_data|
        title = idea_data["title"].to_s.strip
        next if title.blank? || exists?(title: title)

        create!(
          title: title,
          angle: idea_data["angle"].to_s,
          hook: idea_data["hook"].to_s,
          thumbnail_concept: idea_data["thumbnail_concept"].to_s,
          key_points: idea_data["key_points"].to_s,
          hardware_components: idea_data["hardware_components"].to_s,
          difficulty: idea_data["difficulty"].to_s,
          status: "backlog",
          score: idea_data["score"].to_i.clamp(1, 100),
          notes: "AI-generated based on trending topics",
          creator_channel: channel
        )
        created += 1
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.warn("Failed to create AI idea: #{e.message}")
      end

      created
    end
  end
end
