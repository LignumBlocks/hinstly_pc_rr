module Services
  class Scrapper
    def initialize(sources, queries)
      @sources = sources
      @queries = queries
    end

    def scrap!
      @sources.each do |source|
        @queries.each do |query|
          url = source.build_search_url(query)
          response = HTTParty.get(url)
          next unless response.code == 200

          html = Nokogiri::HTML(response.body)
          links = extract_links(query, html)
          links = links['links']

          links&.each do |link|
            if ScrapedResult.exists?(link: link, query_id: query.id, validation_source_id: source.id)
              puts "El link #{link} ya existe en la base de datos, saltando..."
              next
            end

            page_response = HTTParty.get(link)

            if page_response.code == 200
              page_html = Nokogiri::HTML(page_response.body)
              cleaned_content = clean_html_content(page_html.to_html)
              ScrapedResult.create(query_id: query.id, validation_source_id: source.id, link: link,
                                   content: cleaned_content)
            else
              puts "Error al acceder al link #{link}: Código HTTP #{page_response.code}"
            end
          rescue StandardError => e
            puts "Error al procesar el link #{link}: #{e.message}"
            next
          end
        end
      rescue StandardError => e
        next
      end
    end

    private

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
