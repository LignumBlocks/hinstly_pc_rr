module Services
  class Scrapper
    def initialize(sources, queries)
      @sources = sources
      @queries = queries
    end

    # crea los links, siempre va a entrar pero si ya creo un link no lo vuelve a crear
    def prepare_links
      @sources.each do |source|
        @queries.each do |query|
          url = source.build_search_url(query)
          response = HTTParty.get(url)
          next unless response.code == 200

          # html = Nokogiri::HTML(response.body)
          html = response.body # sin limpiar html
          links = extract_links(query, html)
          links = links['links']
          links&.each do |link|
            if ScrapedResult.exists?(link: link, query_id: query.id, validation_source_id: source.id)
              puts "El link #{link} ya existe en la base de datos, saltando..."
              next
            end
            ScrapedResult.create(query_id: query.id, validation_source_id: source.id, link: link)
          end
        rescue StandardError => e
          puts "Error al preparar los links #{url}: #{e.message}"
          next
        end
      end
    end

    # Obtiene todos los registros de soruces+query, sino tiene contenido entonces visita ese link
    def process_links
      @sources.each do |source|
        @queries.each do |query|
          sources_to_visit = ScrapedResult.find_by(query_id: query.id, validation_source_id: source.id)

          sources_to_visit&.each do |visit|
            next unless visit.content?

            page_response = HTTParty.get(visit.link)

            if page_response.code == 200
              page_html = Nokogiri::HTML(page_response.body)
              cleaned_content = clean_html_content(page_html.to_html)
              visit.update(content: cleaned_content)
            else
              puts "Error al acceder al link #{link}: Código HTTP #{page_response.code}"
              next
            end
          end
        end
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
