require 'json'

module Ai
  class HackProcessor

    def verify_hacks_from_text(source_text)
      # Analyzes a piece of text to determine if it constitutes a financial hack, returning a JSON result.

      prompt = Prompt.find_by_code("hack_verification_2")
      prompt_text = prompt.build_prompt_text({ source_text: source_text })
      system_prompt_text = prompt.system_prompt
      
      begin
        model = Ai::LlmHandler.new("gpt-4o-mini")
        result = model.run(prompt_text, system_prompt_text)
        
        cleaned_string = result.gsub("```json\n", "").strip
        json_result = JSON.parse(cleaned_string)
        
      rescue StandardError => e
        puts "Error in verify hacks: #{e.message}"
        return nil
      end
      return json_result
      # is_a_hack = json_result["is_a_hack"]
      # justification = json_result["justification"]
      # hack_title = json_result["possible hack title"]
      # brief_summary = json_result["brief summary"]
      # return [is_a_hack, justification, hack_title,  brief_summary]
    end

    def get_queries_for_validation(hack_title, hack_summary, num_queries = 4)
      # Generates a list of queries to validate a financial hack against real-world sources.

      prompt_template = load_prompt('generate_queries')
      format_hash = { hack_title: hack_title, hack_summary: hack_summary, num_queries: num_queries }
      format_hash.default = ''
      prompt = prompt_template % format_hash
      system_prompt = "You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack."
      
      begin
        model = LlmHandler.new("gpt-4o-mini")
        result = model.run(prompt, system_prompt)
        
        cleaned_string = result.gsub("```json\n", "").gsub("```", "").strip
        json_result = JSON.parse(cleaned_string)
        
      rescue StandardError => e
        puts "Error getting the queries for the hacks: #{e.message}"
        return nil
      end
      return json_result["queries"]
    end

    def get_clean_links(metadata)
      # Extracts non-repeated links from metadata and returns them as a single concatenated string.
      
      links = metadata.map { |item| item[0] }  # Extract the first element from each item
      unique_links = links.uniq                # Get unique links
      result_string = unique_links.join(' ')   # Join them into a single string
      
      result_string
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

      begin
        add_validation_sources_for_hack(hack_id, validation_sources_hashes_list)
        return validation_retrieval_generation(hack_id, hack_title, hack_summary)
      rescue StandardError => e
        puts "Error validating hacks: #{e.message}"
        return nil
      end
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
      
      rag = RAG_LlmHandler.new("gpt-4o-mini", chroma_path: File.join(DATA_DIR, 'chroma_db'))
      rag.store_from_queries(validation_sources_hashes_list, hack_id)
    end
    def validation_retrieval_generation(hack_id, hack_title, hack_summary)
      model = LlmHandler.new("gpt-4o-mini")
      rag = RAG_LlmHandler.new("gpt-4o-mini")
      
      chunks = ""
      metadata = []
      # TODO design a clustering method to select more sources and then make iterations in the validation process or a maxing of the results
      similar_chunks = rag.retrieve_similar_for_hack(hack_id, "#{hack_title}:\n#{hack_summary}")
      similar_chunks.each do |result|
        # puts result.metadata
        metadata << [result.metadata['link'], result.metadata['source']]
        chunks += "#{result.page_content}\n"
      end

      prompt_template = load_prompt('hack_validation')
      format_hash = { chunks: chunks.strip, hack_title: hack_title, hack_summary: hack_summary }
      prompt = prompt_template % format_hash
      system_prompt = "You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack."
      
      result = model.run(prompt, system_prompt)

      begin
        cleaned_string = result.gsub("```json\n", "").gsub("```", "").strip
        json_result = JSON.parse(cleaned_string)
        
        return json_result, prompt, metadata
      rescue JSON::ParserError => e
        puts "Error parsing JSON result: #{e.message}"
        return nil, prompt, metadata
      end
    end

    

  end
end


hack_discrimination0 = "A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.

When scanning content, prioritize hacks that meet the following criteria:

- Clear Financial Value: Must demonstrate measurable financial benefits such as savings, income increases, or tax optimization with impact ranging from minor to significant.
- Originality: Exclude common hacks or widely known financial advice. The hack must offer something unique or little-known.
- Applicability: Must be implementable by users, specifying who can use it and under what conditions (e.g., income level, country).
- Legality and Risks: Must comply with legal standards, highlighting legal implications, tax loopholes, and ethical issues. Key terms: legal complexities, tax exemptions, offshore jurisdictions.
- Clear Explanation: Prioritize hacks offering detailed explanations, preferably in tutorial or step-by-step format.
- Temporal Relevance: Must be suitable for the current economic context. Look for mentions of temporality or economic conditions in which the hack works. Key phrases: \"relevant now\", \"applicable in [current year]\", \"long-term/short-term strategy\".
- Impact Verification: Look for indications of measurable financial impact: specific figures or expected results.

Analize the following content for financial hacks:
---
\#{source_text}
---

The output must be a json with the following structure:
```json
{
    \"possible hack title\": \"<A title of the possible hack in the content. Must be a descriptive name that showcases the particularities of the hack. Try to make it unique.>\",
    \"brief summary\": \"<A short description of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",
    \"justification\": \"<Explanation about whether the content includes a valid financial hack>\",
    \"is_a_hack\": \"<Boolean true or false, about whether the content includes a valid financial hack>\" 
}
```

Scan the content for financial advice or strategies. Evaluate if any hack can be extracted from it.
"
hack_discrimination1 = "A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.

When scanning content, prioritize hacks that meet the following criteria:

- Clear Financial Value: Must demonstrate measurable financial benefits such as savings, income increases, or tax optimization with impact ranging from minor to significant.
- Clear Explanation: Prioritize hacks offering detailed explanations.
- Impact Verification: Look for indications of measurable financial impact: specific figures or expected results.

Analize the following content for financial hacks:
---
\#{source_text}
---

The output must be a json with the following structure:
```json
{
  \"possible hack title\": \"<A title of the possible hack in the content. Must be a descriptive name that showcases the particularities of the hack. Try to make it unique.>\",
  \"brief summary\": \"<A short description of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",
  \"justification\": \"<Explanation about whether the content includes a valid financial hack>\",
  \"is_a_hack\": \"<Boolean true or false, about whether the content includes a valid financial hack>\" 
}
```

Scan the content for financial advice or strategies. Evaluate if any hack can be extracted from it.
"
hack_discrimination2 = "A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.

Analize the following content for financial hacks:
---
\#{source_text}
---

The output must be a json with the following structure:
```json
{
  \"possible hack title\": \"<A title of the possible hack in the content. Must be a descriptive name that showcases the particularities of the hack. Try to make it unique.>\",
  \"brief summary\": \"<A short description of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",
  \"justification\": \"<Explanation about whether the content includes a valid financial hack>\",
  \"is_a_hack\": \"<Boolean true or false, about whether the content includes a valid financial hack>\" 
}
```

Scan the content for financial advice or strategies. Evaluate if any hack can be extracted from it.
"
hack_verif_0 = Prompt.new(
  name: 'Hack Verification Extended', 
  code: 'hack_verification_0', 
  prompt: hack_discrimination0, 
  system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.')
hack_verif_0.save
hack_verif_1 = Prompt.new(
  name: 'Hack Verification Medium', 
  code: 'hack_verification_1', 
  prompt: hack_discrimination1, 
  system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.')
hack_verif_1.save
hack_verif_2 = Prompt.new(
  name: 'Hack Verification Reduced', 
  code: 'hack_verification_2', 
  prompt: hack_discrimination2, 
  system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.')
hack_verif_2.save

generate_queries = "Given the following financial 'hack', generate a set of {num_queries} relevant queries that allow verifying the validity of the hack. The queries will be used on official financial websites to search for information that can validate or refute the techniques or suggestions of the hack. Make sure to:

- Use key terms from the hack title and summary when possible.
- Keep the queries concise and direct, without unnecessary filler words.
- Formulate the queries in a way that they seek specific information related to the validity of the hack.

The validation should check about legality, risks and temporal relevance.

Financial hack title:
\#{hack_title}
---
Financial hack summary:
\#{hack_summary}

Provide your response only as a JSON object containing a list of the relevant queries, in the following format:

{
    \"queries\": [ ... ]
}
"
gen_queries = Prompt.new(
  name: 'Generate queries for validation', 
  code: 'generate_queries', 
  prompt: generate_queries, 
  system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.')
gen_queries.save

hack_validation = "Here is an extract of relevant context from different web pages:

---
\#{chunks}
---

Given the provided search context, please validate or refute the following financial hack acoording to this factors:
A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.
- Legality and Risks: Must comply with legal standards, highlighting legal implications, tax loopholes, and ethical issues.
- Temporal Relevance: Must be suitable for the current economic context.

Financial hack title:
\#{hack_title}
---
Financial hack summary:
\#{hack_summary}

If the information is not enough to emit an opinion about the validity or you are unsure answer Unknown.
Provide your response only as a JSON object containing the analysis, in the following format:

{
    \"validation analysis\": \"<Deep analysis about the validity of the hack, according to the factors above, it can be in markdown format>\",
    \"validation status\": \"<Valid, Invalid or Unknown accordingly>\"
}
"
val_hack = Prompt.new(
  name: 'RAG for hack validation', 
  code: 'hack_validation', 
  prompt: hack_validation, 
  system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.')
val_hack.save




Ai::HackProcessor.verify_hacks_from_text("This is how I became debt-free and saved my first $10,000. You can do it too, but I want to preface this by saying this is what worked for me. I didn't have TikTok at the time to teach me. I had to learn the hard way, and if I can even help one person learn how to better their life through their finances, it'll be a win to me. As always, do what works for you and your situation. This is just what I did. So first of all, I know you don't want to hear this, but you have to work on your mindset. You're not going to get anywhere with the victim mentality of I can never be debt-free, I can never make more money, etc. Work on a mindset of gratitude. Be grateful for what you already have and say thank you when you pay your bills, even though that's kind of hard to do. The second thing I did was to make a plan for how I was going to do this, and it took me a while to come up with this, but it ended up working for me. So I had my main account, and this is the account that I already had. I decided this was going to be my spending account for any fund money that I had for myself, and it's just a regular checking account. I decided to set up a bill account. It was going to also be a checking account. It can be with the same bank, and this is where I was going to transfer all the money to the bills. So one of my goals was to auto pay all my bills from this account eventually. Then I was going to set an emergency fund up for myself using a high-yield savings account. Doesn't matter what bank or credit union you use. And then I was going to set up sinking funds. I decided to do cash envelopes because so I could hold myself more accountable and see the cash in my hand and understand how it was moving. That's how I started off. Now I do it digital, but I started off with cash envelopes, and it really worked for me. Then I had to create a budget for myself, and something very important to note is that you need to be realistic with your budget. If you know you're probably going to eat fast food or go out to eat budget for that, or else you're going to blow your budget. It is very important to just build the things in that you know you're going to spend and hold yourself accountable for the amounts that you set. If you don't set money for things you want, you're way more likely to blow your budget, and then you're going to be frustrated with yourself. The next step is to put together a plan for my emergency fund. I wanted to save a thousand dollars, so I did a one thousand dollar challenge. I'll put a picture here of the exact challenge I created and used for myself. I hung it on the wall, and every time I contributed something to my emergency fund, I colored in a square, and it really kept me motivated and allowed me to celebrate my wins. Next step is I created a debt plan. How was I going to pay off my debt? I used the snowball method, where you pay things off from the smallest balance to the largest, and then you apply the minimum payments to the next debt once you pay one off. It makes it really easy to pay off your debt over time. Then I started doing side hustles to bring in more money to apply to my emergency fund first, and then my debt. Once that was paid off, I saved up my first 10k. I hope this helps. You can do this too. Stay grateful and stay focused.")