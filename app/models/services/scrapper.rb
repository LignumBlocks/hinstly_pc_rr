def scrap!
  @sources.each do |source|
    @queries.each do |query|
      url = source.build_search_url(query)
      response = HTTParty.get(url)

      if response.code == 200
        html = Nokogiri::HTML(response.body)
        links = extract_links(query, html)
        links = links['links']

        links&.each do |link|
          if ScrapedResult.exists?(link: link)
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
      else
        puts "Error al acceder a la URL #{url}: Código HTTP #{response.code}"
      end
    rescue StandardError => e
      puts "Error al acceder a la URL #{url}: #{e.message}"
      next
    end
  end
end
