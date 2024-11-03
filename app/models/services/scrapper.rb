module Services
  class Scrapper
    def initialize(sources, queries)
      @sources = sources
      @queries = queries
    end

    def prepare_links!
      @sources.each do |source|
        @queries.each do |query|
          url = source.build_search_url(query)
          response = HTTParty.get(url)
          next unless response.code == 200

          base_url = "#{URI.parse(source.url_query).scheme}://#{URI.parse(source.url_query).host}"

          html = response.body
          doc = Nokogiri::HTML(html)

          doc.css('head, metadata, script, style, footer, nav, comment, .ads, .sidebar').remove
          doc.xpath('//comment()').remove

          links = extract_links(query, doc)
          links = links['links']
          links&.each do |link|
            absolute_link = URI.join(base_url, link).to_s
            next if ScrapedResult.exists?(link: absolute_link, query_id: query.id, validation_source_id: source.id)

            ScrapedResult.create(query_id: query.id, validation_source_id: source.id, link: link)
          end
        rescue StandardError => e
          puts e.message
          next
        end
      end
    end

    def process_links!
      scraped_results = ScrapedResult.where(query_id: @queries.ids, validation_source_id: @sources.ids).unprocessed
      scraped_results.each do |scraped_result|
        next unless scraped_result.content.blank?

        page_response = HTTParty.get(scraped_result.link)

        next unless page_response.code == 200

        page_html = Nokogiri::HTML(page_response.body)
        cleaned_content = clean_html_content(page_html.to_html)
        scraped_result.update(content: cleaned_content, processed: true)
      rescue StandardError => e
        puts e.message
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
