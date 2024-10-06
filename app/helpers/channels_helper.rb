module ChannelsHelper
  def class_for_channel_state(channel)
    case channel.state.to_sym
    when :unchecked
      return "bg-gray-100 text-gray-800 text-xs  font-medium border border-gray-300 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300"
    when :checking
      return "bg-blue-100 text-blue-800 text-xs font-medium border border-blue-300 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300"
    when :checked
      return "bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300"
    when :check_failed
      return "bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300"
    end
  end
end