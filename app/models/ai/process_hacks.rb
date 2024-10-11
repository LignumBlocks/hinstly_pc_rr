# frozen_string_literal: true

# This class should be removed

require 'json'


module Ai
  class HackProcessor
    def verify_hacks_from_text(source_text)
      # Analyzes a piece of text to determine if it constitutes a financial hack, returning a JSON result.

      prompt = Prompt.find_by_code('hack_verification_2')
      prompt_text = prompt.build_prompt_text({ source_text: })
      system_prompt_text = prompt.system_prompt

      begin
        model = Ai::LlmHandler.new('gpt-4o-mini')
        result = model.run(prompt_text, system_prompt_text)

        cleaned_string = result.gsub("```json\n", '').strip
        json_result = JSON.parse(cleaned_string)
      rescue StandardError => e
        puts "Error in verify hacks: #{e.message}"
        return nil
      end
      json_result
      # is_a_hack = json_result["is_a_hack"]
      # justification = json_result["justification"]
      # hack_title = json_result["possible hack title"]
      # brief_summary = json_result["brief summary"]
      # return [is_a_hack, justification, hack_title,  brief_summary]
    end

    def get_queries_for_validation(hack_title, hack_summary, num_queries = 4)
      # Generates a list of queries to validate a financial hack against real-world sources.

      prompt_template = load_prompt('generate_queries')
      format_hash = { hack_title:, hack_summary:, num_queries: }
      format_hash.default = ''
      prompt = prompt_template % format_hash
      system_prompt = 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.'

      begin
        model = LlmHandler.new('gpt-4o-mini')
        result = model.run(prompt, system_prompt)

        cleaned_string = result.gsub("```json\n", '').gsub('```', '').strip
        json_result = JSON.parse(cleaned_string)
      rescue StandardError => e
        puts "Error getting the queries for the hacks: #{e.message}"
        return nil
      end
      json_result['queries']
    end

    def get_clean_links(metadata)
      # Extracts non-repeated links from metadata and returns them as a single concatenated string.

      links = metadata.map { |item| item[0] }  # Extract the first element from each item
      unique_links = links.uniq                # Get unique links
      unique_links.join(' ') # Join them into a single string
    end

    def validate_financial_hack(hack_id, hack_title, hack_summary, validation_sources_hashes_list)
      # validation_sources_hashes_list is an array of hashes.
      # Each hash represents a validation source and has the following keys:
      #  - "query": The search query related to the validation source.
      #  - "source_id": Unique identifier for the validation source.
      #  - "link": The URL link to the validation source article.
      #  - "content": The actual content of the validation source (text, code, etc.).
      #  - "source": The webpage of the validation source. (optional)
      #  - "title": The title of the validation source article. (optional)
      #  - "description": A brief description of the validation source. (optional)

      # Validates a financial hack by retrieving relevant documents from a vector store and analyzing the information.

      add_validation_sources_for_hack(hack_id, validation_sources_hashes_list)
      validation_retrieval_generation(hack_id, hack_title, hack_summary)
    rescue StandardError => e
      puts "Error validating hacks: #{e.message}"
      nil
    end

    def add_validation_sources_for_hack(hack_id, validation_sources_hashes_list)
      # validation_sources_hashes_list is an array of hashes.
      # Each hash represents a validation source and has the following keys:
      #  - "query": The search query related to the validation source.
      #  - "source_id": Unique identifier for the validation source.
      #  - "link": The URL link to the validation source article.
      #  - "content": The actual content of the validation source (text, code, etc.).
      #  - "source": The webpage of the validation source. (optional)
      #  - "title": The title of the validation source article. (optional)
      #  - "description": A brief description of the validation source. (optional)

      rag = Ai::RagLlmHandler.new('gpt-4o-mini')
      rag.store_from_queries(validation_sources_hashes_list, hack_id)
    end

    # def validation_retrieval_generation(hack_id, hack_title, hack_summary)
    #   model = LlmHandler.new('gpt-4o-mini')
    #   rag = RAG_LlmHandler.new('gpt-4o-mini')
    #
    #   chunks = ''
    #   metadata = []
    #   # TODO: design a clustering method to select more sources and then make iterations in the validation process or a maxing of the results
    #   similar_chunks = rag.retrieve_similar_for_hack(hack_id, "#{hack_title}:\n#{hack_summary}")
    #   similar_chunks.each do |result|
    #     # puts result.metadata
    #     metadata << [result.metadata['link'], result.metadata['source']]
    #     chunks += "#{result.page_content}\n"
    #   end
    #
    #   prompt_template = load_prompt('hack_validation')
    #   format_hash = { chunks: chunks.strip, hack_title:, hack_summary: }
    #   prompt = prompt_template % format_hash
    #   system_prompt = 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.'
    #
    #   result = model.run(prompt, system_prompt)
    #
    #   begin
    #     cleaned_string = result.gsub("```json\n", '').gsub('```', '').strip
    #     json_result = JSON.parse(cleaned_string)
    #
    #     {
    #       validation_analysis: json_result['validation analysis'],
    #       validation_status: json_result['validation status'],
    #       links: get_clean_links(metadata)
    #     }
    #   rescue JSON::ParserError => e
    #     puts "Error parsing JSON result: #{e.message}"
    #     {
    #       validation_analysis: nil,
    #       validation_status: nil,
    #       links: nil
    #     }
    #   end
    # end

    def get_validated_hack_descriptions(hack_id, hack_title, hack_summary, original_text)
      descriptions = get_hack_description(hack_title, hack_summary, original_text)
      # Improve the descriptions using validation sources
      improved_descriptions = grow_descriptions(hack_id, descriptions['free_description'],
                                                descriptions['premium_description'])
      structured_free, structured_premium = structure_hack_descriptions(improved_descriptions['free_description'],
                                                                        improved_descriptions['premium_description'])
      {
        hack_title: structured_free['Hack Title'],
        description: structured_free['Description'],
        main_goal: structured_free['Main Goal'],
        steps_summary: structured_free['steps(Summary)'],
        resources_needed: structured_free['Resources Needed'],
        expected_benefits: structured_free['Expected Benefits'],
        extended_title: structured_premium['Extended Title'],
        detailed_steps: structured_premium['Detailed steps'],
        additional_tools_resources: structured_premium['Additional Tools and Resources'],
        case_study: structured_premium['Case Study']
      }
    end

    def grow_descriptions(hack_id, free_description, premium_description, times = 6, k = 5)
      # Initialize RAG LLM model and retrieve documents similar to the hack
      rag = RAG_LlmHandler.new('gpt-4o-mini')
      documents = rag.retrieve_similar_for_hack(hack_id, "#{free_description}\\n#{premium_description}", k: k * times)
      documents.shuffle! # Randomize the order of elements in the list

      latest_free = free_description
      latest_premium = premium_description

      # Extend the descriptions using document chunks
      (0...times).each do |i|
        chunks = documents[i * k, k].map do |document|
          "Relevant context section:\n\"\"\"#{document.page_content}\n\"\"\""
        end.join("\n")
        puts "Extending descriptions: iter = #{i + 1}"

        improved_descriptions = improve_hack_descriptions(latest_free, latest_premium, chunks)
        latest_free = improved_descriptions['free_description']
        latest_premium = improved_descriptions['premium_description']
      end
      {
        free_description: latest_free,
        premium_description: latest_premium
      }
    end

    def get_hack_description(hack_title, hack_summary, original_text)
      # Performs a deep analysis of a financial hack by generating both free and premium-level analysis.

      prompt_free = Prompt.find_by_code('free_description')
      prompt_premium = Prompt.find_by_code('premium_description')

      format_hash_free = { hack_title:, hack_summary:, original_text: }
      prompt_text_free = prompt_free.build_prompt_text(format_hash_free)
      system_prompt = prompt_free.system_prompt

      begin
        model = Ai::LlmHandler.new('gpt-4o-mini')
        result_free = model.run(prompt_text_free, system_prompt)

        # Include the free analysis result in the premium prompt
        format_hash_premium = format_hash_free.merge({ free_analysis: result_free })
        prompt_text_premium = prompt_premium.build_prompt_text(format_hash_premium)
        system_prompt = prompt_free.system_prompt

        result_premium = model.run(prompt_text_premium, system_prompt)

        {
          free_description: result_free,
          premium_description: result_premium
        }
      rescue StandardError => e
        puts "Error in generating hack description: #{e.message}"
        {
          free_description: nil,
          premium_description: nil
        }
      end
    end

    def improve_hack_descriptions(free_description, premium_description, chunks)
      # Performs an enriched analysis by further refining both free and premium analyses of a financial hack.

      prompt_free = Prompt.find_by_code('enriched_free_description')
      prompt_premium = Prompt.find_by_code('enriched_premium_description')

      format_hash_free = { chunks:, previous_analysis: free_description }
      prompt_text_free = prompt_free.build_prompt_text(format_hash_free)
      system_prompt = prompt_free.system_prompt

      begin
        model = Ai::LlmHandler.new('gpt-4o-mini')
        result_free = model.run(prompt_text_free, system_prompt)

        format_hash_premium = { chunks:, free_analysis: result_free, previous_analysis: premium_description }
        prompt_text_premium = prompt_premium.build_prompt_text(format_hash_premium)

        result_premium = model.run(prompt_text_premium, system_prompt)

        {
          free_description: result_free,
          premium_description: result_premium
        }
      rescue StandardError => e
        puts "Error in improving hack descriptions: #{e.message}"
        {
          free_description: nil,
          premium_description: nil
        }
      end
    end

    def structure_hack_descriptions(free_description, premium_description)
      # Extracts the structured information from the free hack description and the premium hack description.
      prompt_free = Prompt.find_by_code('structured_free_description')
      prompt_premium = Prompt.find_by_code('structured_premium_description')
      format_hash_free = { free_analysis: free_description }
      prompt_text_free = prompt_free.build_prompt_text(format_hash_free)
      system_prompt = prompt_free.system_prompt
      format_hash_premium = { premium_analysis: premium_description }
      prompt_text_premium = prompt_premium.build_prompt_text(format_hash_premium)

      begin
        model = Ai::LlmHandler.new('gpt-4o-mini')
        # Run the model for the free description
        result_free = model.run(prompt_text_free, system_prompt)
        result_premium = model.run(prompt_text_premium, system_prompt)
        result_free = result_free.gsub("```json\n", '').gsub('```', '').strip
        result_premium = result_premium.gsub("```json\n", '').gsub('```', '').strip
        # Parse the JSON results
        {
          structured_free: JSON.parse(result_free),
          structured_premium: JSON.parse(result_premium)
        }
      rescue JSON::ParserError => e
        puts "JSON Parsing Error in structure_hack_descriptions: #{e.message}"
        {
          structured_free: nil,
          structured_premium: nil
        }
      rescue StandardError => e
        puts "Error in structuring hack descriptions: #{e.message}"
        {
          structured_free: nil,
          structured_premium: nil
        }
      end
    end

    def get_hack_classifications(free_description)
      # Classifies a financial hack based on several parameters using the provided free description.

      prompt_complexity = Prompt.find_by_code('complexity_classification')
      prompt_financial_categories = Prompt.find_by_code('financial_categories_classification')

      format_hash = { hack_description: free_description }
      prompt_text_complexity = prompt_complexity.build_prompt_text(format_hash)
      prompt_text_financial_categories = prompt_financial_categories.build_prompt_text(format_hash)
      system_prompt = 'You are a financial analyst specializing in creating financial hacks for users in the USA.'

      begin
        model = Ai::LlmHandler.new('gpt-4o-mini')

        # Get classification for complexity and categories
        result_complexity = model.run(prompt_text_complexity, system_prompt)
        result_categories = model.run(prompt_text_financial_categories, system_prompt)

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

Ai::HackProcessor.verify_hacks_from_text("This is how I became debt-free and saved my first $10,000. You can do it too, but I want to preface this by saying this is what worked for me. I didn't have TikTok at the time to teach me. I had to learn the hard way, and if I can even help one person learn how to better their life through their finances, it'll be a win to me. As always, do what works for you and your situation. This is just what I did. So first of all, I know you don't want to hear this, but you have to work on your mindset. You're not going to get anywhere with the victim mentality of I can never be debt-free, I can never make more money, etc. Work on a mindset of gratitude. Be grateful for what you already have and say thank you when you pay your bills, even though that's kind of hard to do. The second thing I did was to make a plan for how I was going to do this, and it took me a while to come up with this, but it ended up working for me. So I had my main account, and this is the account that I already had. I decided this was going to be my spending account for any fund money that I had for myself, and it's just a regular checking account. I decided to set up a bill account. It was going to also be a checking account. It can be with the same bank, and this is where I was going to transfer all the money to the bills. So one of my goals was to auto pay all my bills from this account eventually. Then I was going to set an emergency fund up for myself using a high-yield savings account. Doesn't matter what bank or credit union you use. And then I was going to set up sinking funds. I decided to do cash envelopes because so I could hold myself more accountable and see the cash in my hand and understand how it was moving. That's how I started off. Now I do it digital, but I started off with cash envelopes, and it really worked for me. Then I had to create a budget for myself, and something very important to note is that you need to be realistic with your budget. If you know you're probably going to eat fast food or go out to eat budget for that, or else you're going to blow your budget. It is very important to just build the things in that you know you're going to spend and hold yourself accountable for the amounts that you set. If you don't set money for things you want, you're way more likely to blow your budget, and then you're going to be frustrated with yourself. The next step is to put together a plan for my emergency fund. I wanted to save a thousand dollars, so I did a one thousand dollar challenge. I'll put a picture here of the exact challenge I created and used for myself. I hung it on the wall, and every time I contributed something to my emergency fund, I colored in a square, and it really kept me motivated and allowed me to celebrate my wins. Next step is I created a debt plan. How was I going to pay off my debt? I used the snowball method, where you pay things off from the smallest balance to the largest, and then you apply the minimum payments to the next debt once you pay one off. It makes it really easy to pay off your debt over time. Then I started doing side hustles to bring in more money to apply to my emergency fund first, and then my debt. Once that was paid off, I saved up my first 10k. I hope this helps. You can do this too. Stay grateful and stay focused.")