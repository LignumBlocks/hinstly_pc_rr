module Ai
  # A class for managing a Retrieval-Augmented Generation (RAG) model using LLMs and a Chroma vector store.
  # This class allows the addition and retrieval of documents from a vector store for better context-aware conversations.
  class RagLlmHandler < BaseHandler
    def initialize(model_name = 'gpt-4o-mini', temperature = 0.4, collection_name = 'validation')
      super(model_name, temperature)
      @collection_name = collection_name
      create_or_load_vs
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

    # Adds a new document to the Chroma vector store if it doesn't already exist.
    def add_document(hack_id, document_id, documents, metadata)
      @vectorstore.add_texts(texts: documents, metadata: metadata)

      # existing_documents = @vectorstore.get()

      # filtered_documents = existing_documents['metadatas'].select do |doc|
      #   doc["hack_id"] == hack_id && doc["document_id"] == document_id
      # end

      # if filtered_documents.empty?
      #  @vectorstore.add_texts(documents, metadatas: metadata)
      # end
    end

    # Retrieves the top-k most similar documents to the given text for a specific hack ID.
    def retrieve_similar_for_hack(hack_id, text_to_compare, k = 4)
      similar_documents = @vectorstore.similarity_search(
        query: text_to_compare,
        k:,
        filter: { 'hack_id' => hack_id }
      )
      puts similar_documents
      similar_documents
    end

    # Stores documents from a list of query results into the Chroma vector store, splitting them into chunks.
    def store_from_queries(queries_dict, hack_id)
      queries_dict.each do |query_dict|
        next if query_dict['content'].empty? || query_dict['content'] == 'Error al cargar el contenido'

        documents = []
        metadatas = []
        content_chunks = Langchain::Chunker::RecursiveText.new(query_dict['content'], chunk_size: 5000,
                                                               chunk_overlap: 500).chunks

        content_chunks.each do |chunk|
          documents << chunk
          metadatas << query_dict.merge({ 'hack_id' => hack_id })
        end

        add_document(hack_id, query_dict['source_id'], documents, metadatas)
      end
    end
  end
end