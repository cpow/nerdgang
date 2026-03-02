class GenerateIdeaSuggestionsJob < ApplicationJob
  queue_as :default

  def perform(limit: 8)
    Idea.generate_from_trends!(limit: limit)
  end
end
