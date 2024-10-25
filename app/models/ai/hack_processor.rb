module Ai
  class HackProcessor
    def initialize(hack)
      @hack = hack
    end

    def find_queries!
      queries = queries_for_hack
      queries.each { |query| @hack.queries.create(content: query) }
    end

    def validate_financial_hack!
      validation = Ai::RagLlmHandler.new('gemini-1.5-flash-8b').validation_for_hack(@hack)
      @hack.create_hack_validation!(analysis: validation[:analysis], status: validation[:status],
                                    links: validation[:links])
    end

    def extend_hack!
      free_description = hack_description('FREE_DESCRIPTION')
      premium_description = hack_description('PREMIUM_DESCRIPTION', free_description)
      grown_descriptions = grow_descriptions(free_description, premium_description, 6)
      free_structured = hack_structure(grown_descriptions[:free_description], 'STRUCTURED_FREE_DESCRIPTION')
      premium_structured = hack_structure(grown_descriptions[:premium_description], 'STRUCTURED_PREMIUM_DESCRIPTION')
      @hack.create_hack_structured_info!(hack_title: free_structured['Hack Title'],
                                         description: free_structured['Description'],
                                         main_goal: free_structured['Main Goal'],
                                         steps_summary: free_structured['steps(Summary)'],
                                         resources_needed: free_structured['Resources Needed'],
                                         expected_benefits: free_structured['Expected Benefits'],
                                         extended_title: premium_structured['Extended Title'],
                                         detailed_steps: premium_structured['Detailed steps'],
                                         additional_tools_resources: premium_structured['Additional Tools and Resources'],
                                         case_study: premium_structured['Case Study'])
    end

    def classify_hack!
      structured = @hack.hack_structured_info
      classification_results = classification_from_free_description(structured)
      result_complexity = classification_results[:complexity]
      result_financial_categories = classification_results[:financial_categories]

      # Insert complexity classification
      complexity_category_name = result_complexity['category']
      complexity_justification = result_complexity['explanation']
      # Search by the complexity_category_name in the table Category to get the category instance
      category_instance = Category.find_by_name(complexity_category_name)
      HackCategoryRel.create(
        hack: @hack,
        category: category_instance,
        justification: complexity_justification
      )

      # Insert each financial category
      financial_categories = result_financial_categories.map { |item| [item['category'], item['explanation']] }
      financial_categories.each do |category, explanation|
        # Search by category in the table Category to get the category instance
        category_instance = Category.find_by_name(category)
        HackCategoryRel.create(
          hack: @hack,
          category: category_instance,
          justification: explanation
        )
      end
    end

    private

    def queries_for_hack(num_queries = 4)
      prompt = Prompt.find_by_code('GENERATE_QUERIES')
      prompt_text = prompt.build_prompt_text({ num_queries:, hack_title: @hack.title, hack_summary: @hack.summary })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      result = model.run(prompt_text, system_prompt_text)
      result = result.gsub('json', '').gsub('```', '').strip
      JSON.parse(result)['queries']
    end

    def hack_structure(description, prompt_code)
      prompt = Prompt.find_by_code(prompt_code)
      prompt_text = prompt.build_prompt_text({ analysis: description })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      result = model.run(prompt_text, system_prompt_text)
      JSON.parse(result.gsub("```json\n", '').gsub('```', '').strip)
    end

    def enriched_description(description, prompt_code, chunks)
      prompt = Prompt.find_by_code(prompt_code)
      prompt_text = prompt.build_prompt_text({ chunks:, previous_analysis: description })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      model.run(prompt_text, system_prompt_text)
    end

    def hack_description(prompt_code, analysis = '')
      prompt = Prompt.find_by_code(prompt_code)
      prompt_text = prompt.build_prompt_text({ hack_title: @hack.title, hack_summary: @hack.summary,
                                               original_text: @hack.video.transcription.content, analysis: })
      system_prompt_text = prompt.system_prompt
      model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
      model.run(prompt_text, system_prompt_text)
    end

    def grow_descriptions(free_description, premium_description, times, k = 6)
      rag = Ai::RagLlmHandler.new('gemini-1.5-flash-8b')
      documents = rag.retrieve_similar_for_hack(@hack.id.to_s, "#{free_description}\\n#{premium_description}",
                                                k * times)
      documents.shuffle!

      latest_free = free_description
      latest_premium = premium_description

      (0...times).each do |i|
        chunks = documents.each do |document|
          "Relevant context section:\n\"\"\"#{document['metadata']['content']}\n\"\"\""
        end.join("\n")

        latest_free = enriched_description(latest_free, 'ENRICH_FREE_DESCRIPTION', chunks)
        latest_premium = enriched_description(latest_premium, 'ENRICH_PREMIUM_DESCRIPTION', chunks)
      end
      {
        free_description: latest_free,
        premium_description: latest_premium
      }
    end

    def classification_from_free_description(structured)
      hack_title = structured[:hack_title]
      description = structured[:description]
      main_goal = structured[:main_goal]

      # Convert JSON strings to hashes or arrays
      steps_summary = begin
        JSON.parse(structured[:steps_summary])
      rescue StandardError
        structured[:steps_summary]
      end
      resources_needed = begin
        JSON.parse(structured[:resources_needed])
      rescue StandardError
        structured[:resources_needed]
      end
      expected_benefits = begin
        JSON.parse(structured[:expected_benefits])
      rescue StandardError
        structured[:expected_benefits]
      end
      free_description = ''
      free_description << "Hack Title\n"
      free_description << "#{hack_title}\n\n"
      free_description << "Description\n"
      free_description << "#{description}\n\n"
      free_description << "Main Goal\n"
      free_description << "#{main_goal}\n\n"
      free_description << "Steps to implement\n"
      if steps_summary.is_a?(Array)
        steps_summary.each do |step|
          free_description << "- #{step}\n"
        end
      else
        free_description << "#{steps_summary}\n\n"
      end
      # free_description << "Resources Needed\n"
      # if resources_needed.is_a?(Array)
      #   resources_needed.each do |resource|
      #     free_description << "- #{resource}\n"
      #   end
      # else
      #   free_description << "#{resources_needed}\n\n"
      # end
      # free_description << "Expected Benefits\n"
      # if expected_benefits.is_a?(Array)
      #   expected_benefits.each do |benefit|
      #     free_description << "- #{benefit}\n"
      #   end
      # else
      #   free_description << "#{expected_benefits}\n\n"
      # end
      get_hack_classifications(free_description)
    end

    def get_hack_classifications(free_description)
      # Classifies a financial hack based on several parameters using the provided free description.
      prompt_complexity = Prompt.find_by_code('COMPLEXITY_CLASSIFICATION')
      prompt_financial_categories = Prompt.find_by_code('FINANCIAL_CLASSIFICATION')
      format_hash = { hack_description: free_description }
      prompt_text_complexity = prompt_complexity.build_prompt_text(format_hash)
      prompt_text_financial_categories = prompt_financial_categories.build_prompt_text(format_hash)
      system_prompt_text = prompt_complexity.system_prompt
      begin
        model = Ai::LlmHandler.new('gemini-1.5-flash-8b')
        # Get classification for complexity and categories
        result_complexity = model.run(prompt_text_complexity, system_prompt_text)
        result_categories = model.run(prompt_text_financial_categories, system_prompt_text)
        # Clean the resulting strings from the model outputs
        result_complexity = result_complexity.gsub("```json\n", '').gsub('```', '').strip
        result_categories = result_categories.gsub("```json\n", '').gsub('```', '').strip
        # Parse the cleaned JSON strings
        {
          complexity: JSON.parse(result_complexity),
          financial_categories: JSON.parse(result_categories)
        }
      rescue StandardError => e
        puts "Error in hack classification: #{e.message}"
        {
          complexity: nil,
          categories: nil
        }
      end
    end
  end
end
