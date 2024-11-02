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
      @vector_store = Langchain::Vectorsearch::Pgvector.new(
        url: ENV['DATABASE_URL'],
        namespace: @collection_name,
        index_name: 'validation_vectors',
        llm: @llm
      )
      # @vector_store.create_default_schema not working for gemini but works with openai
    end

    # Adds a new document to the Chroma vector store if it doesn't already exist.
    def add_document(texts, scraped_result)
      attempts = 0
      max_attempts = 3

      begin
        attempts += 1
        ids = @vector_store.add_texts(texts: texts)
        scraped_result.validation_vector_ids += ids
        scraped_result.save
      rescue StandardError => e
        retry if attempts < max_attempts
      end
    end

    # Retrieves the top-k most similar documents to the given text for a specific hack ID.
    def retrieve_similar_for_hack(text_to_compare, k = 6)
      @vector_store.similarity_search(
        query: text_to_compare,
        k:
      )
    end

    # Stores documents from a list of query results into the Chroma vector store, splitting them into chunks.
    def store_from_queries(hack)
      scrap_results = ScrapedResult.where(query_id: hack.query_ids).unsent_to_pinecone
      scrap_results.each do |scraped_result|
        next unless scraped_result.content

        content_chunks = Langchain::Chunker::RecursiveText.new(scraped_result.content, chunk_size: 2000, chunk_overlap: 300).chunks
        content_chunks.each { |chunk| add_document([chunk.text], scraped_result) }
        scraped_result.update(sent_to_pinecone: true)
      end
    end

    def validation_retrieval_generation(hack)
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      chunks = ''
      links = []
      similar_chunks = retrieve_similar_for_hack("#{hack.title}:\n#{hack.summary}")

      # similar_chunks.each do |chunk|
      #   chunks += "Relevant context section:\n... #{content_chunks[chunk_index].text} ...\n\n"
      #   links << scraped_result.link
      # end
      #
      # prompt = Prompt.find_by_code('HACK_VALIDATION')
      # prompt_text = prompt.build_prompt_text({ chunks: chunks.strip, hack_title: hack.title,
      #                                          hack_summary: hack.summary })
      # system_prompt_text = prompt.system_prompt
      # result = model.run(prompt_text, system_prompt_text)
      # result = JSON.parse(result.gsub("```json\n", '').gsub('```', '').strip)
      # {
      #   analysis: result['validation analysis'],
      #   status: result['validation status'] == 'Valid',
      #   links: links.uniq
      # }
    end
  end
end
