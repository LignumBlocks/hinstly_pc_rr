require 'capybara'
require 'capybara/dsl'

class SourceScrapper
  include Capybara::DSL

  def initialize
    Capybara.current_driver = :selenium_chrome_headless
  end

  def scrap(query)
    results = []
    sources = [
      "https://search.consumerfinance.gov/search?utf8=%E2%9C%93&affiliate=cfpb&query=#{URI.encode_www_form_component(query)}"
    ]
    client = OpenAI::Client.new
    puts "Scraping Consumer Finance for query: #{query}"
    sources.each do |source|
      visit(source)
      response = client.chat(parameters: { model: 'gpt-4o',
                                           messages: [{ role: 'user', content: prompt_for_links(query, page.html) }],
                                           temperature: 0.7 })
      content = response.dig('choices', 0, 'message', 'content')
      content = content.gsub('json', '').gsub('```', '')
      links = JSON.parse(content)['links']

      links.each do |link|
        visit(link)
        puts "Scraping #{link}"
        response = client.chat(parameters: { model: 'gpt-4o',
                                             messages: [{ role: 'user', content: prompt_for_sources(query.question, page.html) }],
                                             temperature: 0.7 })

        content = response.dig('choices', 0, 'message', 'content')
        content = content.gsub('json', '').gsub('```', '')
        ideas = JSON.parse(content)['ideas']
        results << {
          query_id: query.id,
          question: query.question,
          source: source,
          internal_link: link,
          ideas: ideas
        }
      rescue StandardError => e
        puts "fails #{link}"
        next
      end
    end

    results
  end

  private

  def prompt_for_sources(topic, html)
    "Given a string containing HTML code, please extract and return only the relevant text related to a specific topic that I will provide.

      Do not include any HTML elements or JavaScript code in your response; focus solely on the most important texts concerning the requested topic.

      Only extract paragraphs that contain relevant ideas or information about the given topic and return them in a JSON format as follows: { \"ideas\": [ ... ] }.

      Please do not include links or any unrelated text that does not convey a specific idea. The topic is: #{topic} and here is the text: #{html}"
  end

  def prompt_for_links(topic, html)
    "Given a string containing HTML code, please extract and return only the 3 more relevant links related to a specific topic that I will provide.

      Do not include any HTML elements or JavaScript code in your response; focus solely on the most important links concerning the requested topic.

      Only extract links that could contain relevant ideas or information about the given topic and return them in a JSON format as follows: { \"links\": [ ... ] }.

      Please do not include links or any unrelated text that does not convey a specific idea. The topic is: #{topic} and here is the text: #{html}"
  end
end

