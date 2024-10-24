module VideosHelper
  def class_for_state(video)
    case video.state.to_sym
    when :processed
      return 'bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300'
    when :unprocessable
      return 'bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300'
    end
    'bg-gray-100 text-gray-800 text-xs font-medium border border-gray-300 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300'
  end
end