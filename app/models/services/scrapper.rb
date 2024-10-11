require 'capybara'
require 'capybara/dsl'

module Services
  class Scrapper
    include Capybara::DSL

    def initialize(sources, queries)
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless') # Ejecutar en modo cabeza
      options.add_argument('--disable-gpu') # Opcional, para desactivar el uso de GPU
      options.add_argument('--no-sandbox') # Opcional, recomendado para entornos de servidor

      @driver = Selenium::WebDriver.for :chrome, options: options
      # Capybara.current_driver = :selenium_chrome
      @sources = sources
      @queries = queries
      @results = []
    end

    def scrap!
      client = OpenAI::Client.new
      @sources.each do |source|
        @queries.each do |query|
          url = source.build_search_url(query)
          @driver.navigate.to(url)

          response = client.chat(parameters: { model: 'gpt-4o',
                                               messages: [{ role: 'user', content: prompt_for_links(query, @driver.page_source) }],
                                               temperature: 0.7 })
          content = response.dig('choices', 0, 'message', 'content')
          content = content.gsub('json', '').gsub('```', '')
          links = JSON.parse(content)['links']
          links.each do |link|
            already_scraped_content = results_content_by_link(link)
            add_result(query.id, source.id, link, already_scraped_content) and next if already_scraped_content

            @driver.navigate.to(link)
            #Esperar a que el elemento <body> esté presente
            wait = Selenium::WebDriver::Wait.new(timeout: 10)
            wait.until { @driver.find_element(:tag_name, "body").displayed? }
            # Simular scrolling hasta el final de la página para cargar todo el contenido
            @driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            sleep(1)
            # Limpiar el contenido HTML utilizando la función clean_html_content
            cleaned_content = clean_html_content(@driver.page_source)

            add_result(query.id, source.id, link, cleaned_content)

          rescue StandardError => e
            puts "fails link #{e.message}"
            next
          end
        end
        @driver.quit
      end
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

    def prompt_for_links(query, html)
      "Given a string containing HTML code, please extract and return a maximum of the 3 more relevant links related to a specific topic that I will provide,
      You must return them only if they are related but never more than 3 and if it's impossible to find any, dont give any explanation

      Do not include any HTML elements or JavaScript code in your response; focus solely on the most important links concerning the requested topic.

      Only extract links that could contain relevant ideas or information about the given topic and return them in a JSON format as follows: { \"links\": [ ... ] }.

      Please do not include links or any unrelated text that does not convey a specific idea.The topic is: #{query.content} and here is the text: #{html}"
    end

    def clean_html_content(page_source)
      # Utilizar Nokogiri para parsear el contenido HTML
      doc = Nokogiri::HTML(page_source)

      # Remover etiquetas irrelevantes como <script>, <style>, <footer>, <nav>
      doc.css('script, style, footer, nav, comment, .ads, .sidebar').remove

      # Usar Loofah para limpiar el HTML y convertirlo en texto sin formato
      clean_content = Loofah.fragment(doc.to_html).scrub!(:prune).to_text

      # Reemplazar o eliminar los caracteres especiales como &#13;
      clean_content.gsub("&#13;", "").gsub(/\n{2,}/, "\n\n").strip
    end
  end
end

