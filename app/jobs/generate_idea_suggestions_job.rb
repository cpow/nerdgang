class GenerateIdeaSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(limit: 8)
    if Idea.ai_available?
      created = Idea.generate_with_ai!(limit: limit)
      Rails.logger.info("Generated #{created} AI-powered idea suggestions")
    else
      created = Idea.generate_from_trends!(limit: limit)
      Rails.logger.info("Generated #{created} template-based idea suggestions")
    end
    created
  end
end
