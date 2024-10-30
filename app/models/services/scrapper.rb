require 'capybara'
require 'capybara/dsl'
require 'timeout'
require 'connection_pool'
module Services
  class Scrapper
    include Capybara::DSL
    def initialize(sources, queries)
      @options = Selenium::WebDriver::Chrome::Options.new
      @options.add_argument('--headless')
      @options.add_argument('--disable-gpu')
      @options.add_argument('--no-sandbox')
      @options.add_argument('--disable-dev-shm-usage')
      @options.add_argument('--disable-extensions')
      @options.add_argument('--remote-debugging-port=9222')
      @options.add_argument('--disable-blink-features=AutomationControlled')
      @browser_pool = ConnectionPool.new(size: 4, timeout: 5) do
        Selenium::WebDriver.for :chrome, options: @options
      end
      @sources = sources
      @queries = queries
    end
    def scrap!
      @sources.each do |source|
        @queries.each do |query|
          @browser_pool.with do |driver|
            url = source.build_search_url(query)
            navigate_to_url(driver, url)
            links = extract_links(query, driver.page_source)
            process_links(driver, links, source, query)
          rescue StandardError => e
            puts "Error en la fuente #{source.name} y link #{link}: #{e.message}"
            next
          end
        end
      end
    end
    private
    def navigate_to_url(driver, url)
      Timeout.timeout(5) do
        driver.navigate.to(url)
      end
    rescue Timeout::Error
      puts "Timeout alcanzado al intentar navegar a #{url}"
    end
    def process_links(driver, links, source, query)
      links['links']&.each do |link|
        puts "Error en la fuente #{source.name} y link #{link}"
        navigate_to_url(driver, link)
        wait_for_content(driver)
        cleaned_content = clean_html_content(driver.page_source)
        ScrapedResult.create(query_id: query.id, validation_source_id: source.id, link: link, content: cleaned_content)
      rescue StandardError => e
        puts "Error en el enlace #{link}: #{e.message}"
        next

      end
    end
    def wait_for_content(driver)
      wait = Selenium::WebDriver::Wait.new(timeout: 3)
      wait.until { driver.find_element(:tag_name, 'body').displayed? }
      driver.execute_script('window.scrollTo(0, document.body.scrollHeight);')
    rescue Selenium::WebDriver::Error::TimeoutError
      puts "Tiempo de espera agotado para cargar el contenido del body"
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
      doc.css('script, style, footer, nav, comment, .ads, .sidebar, #header, #footer').remove
      clean_content = doc.css('body').text.strip
      clean_content.gsub('&#13;', '').gsub(/\n{2,}/, "\n\n").strip
    end
  end
end