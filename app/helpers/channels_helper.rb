module ChannelsHelper
  def class_for_state(channel)
    case channel.state
    when Channel::UNCHECKED_STATE
      return "bg-yellow-100 text-yellow-800 text-xs me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300"
    when Channel::CHECKING_STATE
      return "bg-blue-100 text-blue-800 text-xs font-medium border border-blue-300 px-0 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300"
    when Channel::CHECKED_STATE
      return "bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300"
    when Channel::CHECK_FAILED_STATE
      return "bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300"
    end
  end
end