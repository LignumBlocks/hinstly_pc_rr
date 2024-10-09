# require 'langchain'
# require 'openai'
require 'dotenv'
Dotenv.load

module Ai
  class LlmHandler
    OPENAI_API_KEY = ENV['OPENAI_API_KEY']
    GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']

    MODELS = %w[gpt-4o-mini gpt-3.5-turbo gemini-1.5-flash].freeze

    DEFAULT_SYSTEM_PROMPT = 'You are a helpful assistant. Answer all questions to the best of your ability.'.freeze

    attr_reader :model_name, :llm

    def initialize(model_name = 'gpt-4o-mini', temperature = 0.7)
      @model_name = MODELS.include?(model_name) ? model_name : MODELS[0]
      @temp = temperature

      @llm = if @model_name.include?('gpt')
               load_openai
             else
               load_gemini
             end
    end

    def load_openai
      Langchain::LLM::OpenAI.new(
        api_key: OPENAI_API_KEY, default_options: { temperature: @temp, chat_completion_model_name: @model_name,
                                                    embeddings_model_name: 'text-embedding-3-small' }
      )
    end

    def load_gemini
      Langchain::LLM::GoogleGemini.new(
        api_key: OPENAI_API_KEY,
        default_options: { temperature: @temp,
                           chat_completion_model_name: @model_name,
                           embeddings_model_name: 'text-embedding-004' }
      )
    end

    def run(input, system_prompt = DEFAULT_SYSTEM_PROMPT)
      # Executes a conversation with the LLM based on the provided input and optional system prompt.

      messages = [
        { role: 'system', content: system_prompt },
        { role: 'user', content: input }
      ]
      response = @llm.chat(messages:)

      puts "Chat response: #{response}"
      response.chat_completion
    end
  end

  class RagLlmHandler
    # A class for managing a Retrieval-Augmented Generation (RAG) model using LLMs and a Chroma vector store.
    # This class allows the addition and retrieval of documents from a vector store for better context-aware conversations.

    # attr_reader :model_name, :llm, :vectorstore

    def initialize(model_name = 'gpt-4o-mini', temperature = 0.4, collection_name = 'validation')
      # Initializes the RAGLLMModel with the specified parameters.
      @model_name = MODELS.include?(model_name) ? model_name : MODELS[0]
      @temp = temperature
      @collection_name = collection_name
      # Select the appropriate LLM model
      @llm = if @model_name.include?('gpt')
               load_openai
             else
               load_gemini
             end
      create_or_load_vs
    end

    def load_openai
      Langchain::LLM::OpenAI.new(
        api_key: OPENAI_API_KEY, default_options: { temperature: @temp, chat_completion_model_name: @model_name,
                                                    embeddings_model_name: 'text-embedding-3-small' }
      )
    end

    def load_gemini
      Langchain::LLM::GoogleGemini.new(
        api_key: OPENAI_API_KEY,
        default_options: { temperature: @temp,
                           chat_completion_model_name: @model_name,
                           embeddings_model_name: 'text-embedding-004' }
      )
    end

    def create_or_load_vs
      @vectorstore = Langchain::Vectorsearch::Pinecone.new(
        environment: ENV['PINECONE_ENVIRONMENT'],
        api_key: ENV['PINECONE_API_KEY'],
        index_name: @collection_name,
        llm: @llm
      )
      @vectorstore.create_default_schema
    end

    def add_document(hack_id, document_id, documents, metadata)
      # Adds a new document to the Chroma vector store if it doesn't already exist.
      @vectorstore.add_texts(texts: documents, metadatas: metadata)

      # existing_documents = @vectorstore.get()

      # filtered_documents = existing_documents['metadatas'].select do |doc|
      #   doc["hack_id"] == hack_id && doc["document_id"] == document_id
      # end

      # if filtered_documents.empty?
      #  @vectorstore.add_texts(documents, metadatas: metadata)
      # end
    end

    def retrieve_similar_for_hack(hack_id, text_to_compare, k = 4)
      # Retrieves the top-k most similar documents to the given text for a specific hack ID.

      similar_documents = @vectorstore.similarity_search(
        query: text_to_compare,
        k:,
        filter: { 'hack_id' => hack_id }
      )
      puts similar_documents
      similar_documents
    end

    def store_from_queries(queries_dict, hack_id)
      # Stores documents from a list of query results into the Chroma vector store, splitting them into chunks.

      queries_dict.each do |query_dict|
        next if query_dict['content'].empty? || query_dict['content'] == 'Error al cargar el contenido'

        documents = []
        metadatas = []
        content_chunks = Langchain::Chunker::RecursiveText.new(query_dict['content'], chunk_size: 5000,
                                                                                      chunk_overlap: 500).chunks

        content_chunks.each do |chunk|
          documents << chunk
          metadatas << query_dict.merge({
                                          'hack_id' => hack_id
                                        })
        end

        add_document(hack_id, query_dict['source_id'], documents, metadatas)
      end
    end
  end
end
