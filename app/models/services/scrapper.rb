require 'capybara'
require 'capybara/dsl'

module Services
  class Scrapper
    include Capybara::DSL

    def initialize(sources, queries)
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      options.add_argument('--no-sandbox')

      @driver = Selenium::WebDriver.for :chrome, options: options
      @sources = sources
      @queries = queries
      @results = []
    end

    def scrap!
      @sources.each do |source|
        @queries.each do |query|
          url = source.build_search_url(query)
          @driver.navigate.to(url)

          links = extract_links(query, @driver.page_source)
          links = links['links']
          links&.each do |link|
            already_scraped_content = results_content_by_link(link)
            add_result(query.id, source.id, link, already_scraped_content) and next if already_scraped_content

            @driver.navigate.to(link)

            wait = Selenium::WebDriver::Wait.new(timeout: 10)
            wait.until { @driver.find_element(:tag_name, 'body').displayed? }
            @driver.execute_script('window.scrollTo(0, document.body.scrollHeight);')

            cleaned_content = clean_html_content(@driver.page_source)

            add_result(query.id, source.id, link, cleaned_content)

          rescue StandardError => e
            puts "fails link #{e.message}"
            next
          end
        end
      end
      @driver.quit
      @results.each do |result|
        ScrapedResult.create(query_id: result[:query_id],
                             validation_source_id: result[:validation_source_id],
                             link: result[:link],
                             content: result[:content])
      end
    end

    private

    def add_result(query_id, source_id, link, content)
      @results << { query_id: query_id, validation_source_id: source_id, link: link, content: content }
    end

    def results_content_by_link(link)
      result = @results.find { |r| r[:link] == link }
      result ? result[:content] : nil
    end

    def extract_links(query, html)
      prompt = Prompt.find_by_code('SCRAP_LINKS')
      prompt_text = prompt.build_prompt_text({ query: query.content, content: html })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      result = model.run(prompt_text, system_prompt_text)
      result = result.gsub('json', '').gsub('```', '').strip
      JSON.parse(result)
    end

    def clean_html_content(page_source)
      doc = Nokogiri::HTML(page_source)
      doc.css('script, style, footer, nav, comment, .ads, .sidebar').remove
      clean_content = Loofah.fragment(doc.to_html).scrub!(:prune).to_text
      clean_content.gsub('&#13;', '').gsub(/\n{2,}/, "\n\n").strip
    end
  end
end

