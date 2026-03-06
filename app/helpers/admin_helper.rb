module AdminHelper
  include Pagy::Method

  def status_badge_class(status)
    case status.to_s
    when "backlog"
      "bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300"
    when "researching"
      "bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300"
    when "scripting"
      "bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300"
    when "filmed"
      "bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300"
    when "published"
      "bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300"
    else
      "bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300"
    end
  end

  def difficulty_badge_class(difficulty)
    case difficulty.to_s
    when "beginner"
      "bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300"
    when "intermediate"
      "bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300"
    when "advanced"
      "bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300"
    else
      "bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300"
    end
  end
end
