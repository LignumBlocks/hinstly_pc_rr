module Ai
  # A class for managing a Retrieval-Augmented Generation (RAG) model using LLMs and a Chroma vector store.
  # This class allows the addition and retrieval of documents from a vector store for better context-aware conversations.
  class RagLlmHandler < BaseHandler
    attr_reader :model_name, :llm
    def initialize(model_name = 'gpt-4o-mini', temperature = 0.4, collection_name = 'validation')
      super(model_name, temperature)
      @collection_name = collection_name
      create_or_load_vs
    end

    def validation_for_hack(hack)
      store_from_queries(validation_sources_hashes_list(hack), hack.id)
      validation_retrieval_generation(hack.id, hack.title, hack.summary)
    end

    def create_or_load_vs
      environment = if @model_name.include?('gpt')
                ENV.fetch('PINECONE_ENVIRONMENT_OPENAI')
              else
                ENV.fetch('PINECONE_ENVIRONMENT_OPEN_SOURCE')
              end
      @vector_store = Langchain::Vectorsearch::Pinecone.new(
        environment: environment,
        api_key: ENV.fetch('PINECONE_API_KEY'),
        index_name: 'hintsly-rag-openai',
        llm: @llm
      )
      @vector_store.create_default_schema
    end

    # Adds a new document to the Chroma vector store if it doesn't already exist.
    def add_document(documents, metadata)
      @vector_store.add_texts(texts: documents, metadata:)
    end

    # Retrieves the top-k most similar documents to the given text for a specific hack ID.
    def retrieve_similar_for_hack(hack_id, text_to_compare, k = 4)
      similar_documents = @vector_store.similarity_search(
        query: text_to_compare,
        # k:,
        # filter: { 'hack_id' => hack_id }
      )
      puts similar_documents
      similar_documents
    end

    # Stores documents from a list of query results into the Chroma vector store, splitting them into chunks.
    def store_from_queries(queries_dict, hack_id)
      queries_dict.each do |query_dict|
        next unless query_dict['content']

        documents = []
        metadata = []
        content_chunks = Langchain::Chunker::RecursiveText.new(query_dict['content'], chunk_size: 5000,
                                                                                      chunk_overlap: 500).chunks
        content_chunks.each do |chunk|
          documents << chunk
          metadata << query_dict.merge({ 'hack_id' => hack_id })
        end
        add_document(documents, metadata)
      end
    end

    def validation_retrieval_generation(hack_id, hack_title, hack_summary)
      model = Ai::LlmHandler.new('gpt-4o-mini')
      chunks = ''
      metadata = []
      # TODO: design a clustering method to select more sources and then make iterations in the validation process or a maxing of the results
      similar_chunks = retrieve_similar_for_hack(hack_id, "#{hack_title}:\n#{hack_summary}")
      similar_chunks.each do |result|
        metadata << [result.metadata['link'], result.metadata['source']]
        chunks += "#{result.page_content}\n"
      end
      prompt = Prompt.find_by_code('HACK_VALIDATION')
      prompt_text = prompt.build_prompt_text({ chunks: chunks.strip, hack_title:, hack_summary: })
      system_prompt_text = prompt.system_prompt
      result = model.run(prompt_text, system_prompt_text)
      result = JSON.parse(result.gsub("```json\n", '').gsub('```', '').strip)
      {
        analysis: result['validation analysis'],
        status: result['validation status'] == 'Valid',
        links: get_clean_links(metadata)
      }
    end

    def get_clean_links(metadata)
      links = metadata.map { |item| item[0] }
      unique_links = links.uniq
      unique_links.join(' ')
    end

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
