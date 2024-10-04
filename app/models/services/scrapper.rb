require 'capybara'
require 'capybara/dsl'

module Services
  class Scrapper
    include Capybara::DSL

    def initialize(sources, queries)
      Capybara.current_driver = :selenium_chrome_headless
      @sources = sources
      @queries = queries
    end

    def scrap!
      client = OpenAI::Client.new
      @sources.each do |source|
        @queries.each do |query|
          visit(source.build_search_url(query))

          response = client.chat(parameters: { model: 'gpt-4o',
                                               messages: [{ role: 'user', content: prompt_for_links(query, page.html) }],
                                               temperature: 0.7 })
          content = response.dig('choices', 0, 'message', 'content')
          content = content.gsub('json', '').gsub('```', '')
          links = JSON.parse(content)['links']
          links.each do |link|
            visit(link)
            ScrapedResult.create(query: query, validation_source: source, link: link, content: page.html)

          rescue StandardError => e
            puts "fails link #{e.message}"
            next
          end
        end
      end
    end

    private

    def prompt_for_links(query, html)
      "Given a string containing HTML code, please extract and return a maximum of the 3 more relevant links related to a specific topic that I will provide,
      You must return them only if they are related but never more than 3.

      Do not include any HTML elements or JavaScript code in your response; focus solely on the most important links concerning the requested topic.

      Only extract links that could contain relevant ideas or information about the given topic and return them in a JSON format as follows: { \"links\": [ ... ] }.

      Please do not include links or any unrelated text that does not convey a specific idea.The topic is: #{query.content} and here is the text: #{html}"
    end
  end
end

