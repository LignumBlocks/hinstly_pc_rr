module ApplicationHelper
  include Pagy::Frontend
  include Heroicon::Engine.helpers

  def page_title
    "Rails + Ralix + Tailwind | #{controller_name.humanize}"
  end

  def body_class
    "#{controller_name}-#{action_name}"
  end

  def nav_link_class(section, extra = nil)
    if section == controller_name
      "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium #{extra}"
    else
      "text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium #{extra}"
    end
  end

  def time_ago(time_object)
    "#{time_ago_in_words(time_object)} ago"
  end

  def format_time(time_object)
    l(time_object, format: :long)
  end

  def class_for_boolean(flag)
    if flag
      return 'bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300'
    end

    'bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300'
  end

  def format_number(number)
    case number
    when 1_000..999_999 then "#{(number / 1_000.0).round(1)}k"
    when 1_000_000..999_999_999 then "#{(number / 1_000_000.0).round(1)}M"
    else number.to_s
    end
  end

  def class_for_boolean(flag)
    if flag
      return 'bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300'
    end

    'bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300'
  end

  def text_for_boolean(flag)
    if flag
      'Yes'
    else
      'No'
    end
  end

  def capitalize_first_letter(sentence)
    sentence[0] = sentence[0].capitalize if sentence.present?
    sentence
  end

  def compact_number(number)
    case number
    when 1_000_000_000..Float::INFINITY
      "#{(number / 1_000_000_000.0).round(1)}B+"
    when 1_000_000..999_999_999
      "#{(number / 1_000_000.0).round(1)}M+"
    when 1_000..999_999
      "#{(number / 1_000.0).round(1)}K+"
    else
      number.to_s
    end
  end
end
