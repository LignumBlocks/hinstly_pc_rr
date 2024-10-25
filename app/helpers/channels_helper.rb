module ChannelsHelper
  def class_for_channel_state(channel)
    case channel.state.to_sym
    when :processed
      'bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300'
    else
      'bg-gray-100 text-gray-800 text-xs  font-medium border border-gray-300 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300'
    end
  end
end
