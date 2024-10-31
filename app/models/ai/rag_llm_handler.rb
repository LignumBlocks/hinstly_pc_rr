module Ai
  # A class for managing a Retrieval-Augmented Generation (RAG) model using LLMs and a Chroma vector store.
  # This class allows the addition and retrieval of documents from a vector store for better context-aware conversations.
  class RagLlmHandler < BaseHandler
    attr_reader :model_name, :llm, :collection_name

    def initialize(model_name = 'gemini-1.5-flash-8b', temperature = 0.4, collection_name = 'validation')
      super(model_name, temperature)
      @collection_name = collection_name
      create_or_load_vs
    end

    def validation_for_hack(hack)
      store_from_queries(hack)
      validation_retrieval_generation(hack)
    end

    def create_or_load_vs
      environment = if @model_name.include?('gpt')
                      ENV.fetch('PINECONE_ENVIRONMENT_OPENAI')
                    else
                      ENV.fetch('PINECONE_ENVIRONMENT_GEMINI')
                    end
      @vector_store = Langchain::Vectorsearch::Pinecone.new(
        environment:,
        api_key: ENV.fetch('PINECONE_API_KEY'),
        index_name: 'hintsly-rag-gemini',
        llm: @llm
      )
      @vector_store.create_default_schema
    end

    # Adds a new document to the Chroma vector store if it doesn't already exist.
    def add_document(texts, metadata)
      @vector_store.add_texts(texts:, namespace: @collection_name, metadata:)
    end

    # Retrieves the top-k most similar documents to the given text for a specific hack ID.
    def retrieve_similar_for_hack(namespace, text_to_compare, filter_hash, k = 6)
      @vector_store.similarity_search(
        query: text_to_compare,
        k:,
        namespace:,
        filter: filter_hash
      )
    end

    # Stores documents from a list of query results into the Chroma vector store, splitting them into chunks.
    def store_from_queries(hack)
      hack.queries.each do |query|
        query.scraped_results.each do |scraped_result|
          next unless scraped_result.content

          content_chunks = Langchain::Chunker::RecursiveText.new(scraped_result.content, chunk_size: 2000,
                                                                                         chunk_overlap: 300).chunks
          content_chunks.each do |chunk|
            metadata = { "hack_id": hack.id.to_s, "query": query.content, "link": scraped_result.link,
                         "content": chunk.text }
            add_document([chunk.text], metadata)
          end
        end
      end
    end

    def validation_retrieval_generation(hack)
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      chunks = ''
      links = []
      # TODO: design a clustering method to select more sources and then make iterations in the validation process or a maxing of the results
      similar_chunks = retrieve_similar_for_hack(@collection_name, "#{hack.title}:\n#{hack.summary}",
                                                 { "hack_id": hack.id.to_s })
      similar_chunks.each do |result|
        links << result['metadata']['link']
        chunks += "Relevant context section:\n#{result['metadata']['content']}\n\n"
      end
      prompt = Prompt.find_by_code('HACK_VALIDATION')
      prompt_text = prompt.build_prompt_text({ chunks: chunks.strip, hack_title: hack.title,
                                               hack_summary: hack.summary })
      system_prompt_text = prompt.system_prompt
      result = model.run(prompt_text, system_prompt_text)
      result = JSON.parse(result.gsub("```json\n", '').gsub('```', '').strip)
      {
        analysis: result['validation analysis'],
        status: result['validation status'] == 'Valid',
        links: links.uniq
      }
    end

    # deprecated
    def get_clean_links(metadata)
      links = metadata.map { |item| item[0] }
      unique_links = links.uniq
      unique_links.join(' ')
    end

    # deprecated
    def validation_sources_hashes_list(hack)
      hashes = []
      hack.queries.each do |query|
        query.scraped_results.each do |scraped_result|
          hashes << {
            query: query.content,
            source_id: scraped_result.validation_source_id,
            link: scraped_result.link,
            content: scraped_result.content
          }
        end
      end
      hashes
    end
  end
end
