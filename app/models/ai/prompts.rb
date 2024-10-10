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
  system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.'
)
hack_verif_0.save
hack_verif_1 = Prompt.new(
  name: 'Hack Verification Medium',
  code: 'hack_verification_1',
  prompt: hack_discrimination1,
  system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.'
)
hack_verif_1.save
hack_verif_2 = Prompt.new(
  name: 'Hack Verification Reduced',
  code: 'hack_verification_2',
  prompt: hack_discrimination2,
  system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.'
)
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
  system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.'
)
gen_queries.save

hack_validation = "Here is an extract of relevant context from different web pages:

  ---
  \#{chunks}
  ---

  Given the provided search context, please validate or refute the following financial hack according to this factors:
  A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.
  - Legality and Risks: Must comply with legal standards, highlighting legal implications, tax loopholes, and ethical issues.
  - Temporal Relevance: Must be suitable for the current economic context.

  Financial hack title:
  \#{hack_title}
  ---
  Financial hack summary:
  \#{hack_summary}

  If the information is not enough to emit an opinion about the validity or you are unsure answer Invalid.
  Provide your response only as a JSON object containing the analysis, in the following format:

  {
      \"validation analysis\": \"<Deep analysis about the validity of the hack, according to the factors above>\",
      \"validation status\": \"<Valid, Invalid>\"
  }
  "
val_hack = Prompt.new(
  name: 'RAG for hack validation',
  code: 'hack_validation',
  prompt: hack_validation,
  system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.'
)
val_hack.save

free_description = "You are an expert financial analyst with a deep understanding of financial hacks and strategies.

Hack Title:
\#{hack_title}
---
Summary:
\#{hack_summary}
---
Source Text of the Hack:
\#{original_text}
---

Your task is to provide a comprehensive analysis of the financial hack described above, adhering to the following guidelines. The result will be read directly by a user, keep that in mind. The analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.

The output format mut not include bold (`**`) or italic (`*`). And the format should follow this structure and guidelines.

# Hack Title:
  Provide a concise and engaging title for the hack.

## Description:
  Summarize the hack's concept and benefits in 2-3 sentences. Highlight how the hack improves the user's financial situation or habits. Make it concise and objective

## Main Goal:
  Clearly state the hack's primary purpose in one sentence.

## Steps for Implementation (Summary):
  List 3-5 concise, actionable steps for the user to implement the hack.
  Ensure the steps are clear and simple enough for any user to follow without advanced knowledge.

## Resources Needed:
  List the essential tools, apps, or bank accounts necessary to implement the strategy effectively (e.g., specific apps, online banks, calculators).

## Expected Benefits:
  Briefly outline the financial or psychological benefits of applying the hack (e.g., improved savings discipline, accelerated debt payoff, reduced stress, etc.)."

free_desc = Prompt.new(
  name: 'Initial FREE description',
  code: 'free_description',
  prompt: free_description,
  system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.'
)
free_desc.save

premium_description = "You are an expert financial analyst with a deep understanding of financial hacks and strategies.

Hack Title:
\#{hack_title}
---
Summary:
\#{hack_summary}
---
Source Text of the Hack:
\#{original_text}
---
Simplified analysis
\#{free_analysis}
---

Your task is to provide a comprehensive analysis of the financial hack described above, adhering to the following guidelines. The result will be read directly by a user, keep that in mind.
Your Analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.

The output format mut not include bold (`**`) or italic (`*`). And the format should follow this structure and guidelines.

# Extended Title:
  Provide an extended version of the title in the `Simplified analysis` to reflect the in-depth content.

## Detailed Steps for Implementation:
  Offer an extended breakdown of each step listed in the `Simplified analysis`, including additional details and context to optimize the hack.
  Ensure the steps are clear for any user to follow without advanced knowledge.
  Include personalized tips, tricks, and insights to help the users tailor the strategy to their personal finances.
  Explain advanced considerations that could help users maximize the hack.

## Additional Tools and Resources:
  Suggest advanced apps, bank accounts that users can use to enhance the strategy.
  Provide recommendations for tools that offer more complex tracking, customization, or integration with other financial plans (e.g., debt payoff calculators, investment tools, detailed budgeting systems).

## Case Study Outline:
  Provide a brief outline for a realistic case study that demonstrates how a hypothetical user applies the hack and benefits from it."
premium_desc = Prompt.new(
  name: 'Initial PREMIUM description',
  code: 'premium_description',
  prompt: premium_description,
  system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.'
)
premium_desc.save

enriched_free_description = "You are an expert financial analyst with a deep understanding of financial hacks and strategies.

Here is an extract of relevant context from different web pages:
\#{chunks}
---

Hack description:
\#{previous_analysis}
---

Your task is to analyze each section in the hack description and extend it with the information provided in the context.
The analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.
Maintain the structure and the speech style from the `Hack description`. The title must be concise and engaging, don't change it if it is not necessary.

The output format mut not include bold (`**`) or italic (`*`). And the format should follow this structure and guidelines.

# Hack Title:
  Concise and engaging title for the hack.
## Description:
  Summarized hack's concept and benefits. Objective analysis of how the hack improves the user's financial situation or habits.
## Main Goal:
  Hack's primary purpose.
## Steps for Implementation (Summary):
  3-5 concise, actionable steps to implement the hack. Clear and simple enough for any user to follow without advanced knowledge.
## Resources Needed:
  List of the essential tools, apps, or bank accounts necessary to implement the strategy effectively.
## Expected Benefits:
  Outline of the benefits of applying the hack."
enriched_free_desc = Prompt.new(
  name: 'Enriched FREE description',
  code: 'enriched_free_description',
  prompt: enriched_free_description,
  system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.'
)
enriched_free_desc.save

enriched_premium_description = "You are an expert financial analyst with a deep understanding of financial hacks and strategies.

Here is an extract of relevant context from different web pages:
\#{chunks}
---
Simplified analysis
\#{free_analysis}
---

Hack description:
\#{previous_analysis}
---

Your task is to analyze each section in the hack description and extend it with the information provided in the context above.
The analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.
Maintain the structure and the speech style from the `Hack description`. The title must be concise and engaging, don't change it if it is not necessary.

The output format mut not include bold (`**`) or italic (`*`). And the format should follow this structure and guidelines.

# Extended Title:
  Extended version of the title in the `Simplified analysis` to reflect the in-depth content.
## Detailed Steps for Implementation:
  Extended breakdown of each step listed in the `Simplified analysis`, including additional details and context to optimize the hack. The steps must br clear for any user to follow without advanced knowledge. With advanced considerations that could help users maximize the benefits of the hack.
## Additional Tools and Resources:
  Advanced apps, bank accounts and services that users can use to enhance the strategy. Recommendations for tools that offer more complex tracking, customization, or integration with other financial plans (e.g., debt payoff calculators, investment tools, detailed budgeting systems).
## Case Study Outline:
  Brief outline for a realistic case study that demonstrates how a hypothetical user applies the hack and benefits from it."
enriched_premium_desc = Prompt.new(
  name: 'Enriched PREMIUM description',
  code: 'enriched_premium_description',
  prompt: enriched_premium_description,
  system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.'
)
enriched_premium_desc.save

structured_free_description = "You are an expert financial analyst with a deep understanding of financial hacks and strategies.

Hack analysis
\#{free_analysis}
---

Your task is to structure the provided analysis into a json dictionary. The itemized objects should be saved as lists, the section titles should be dictionary keys. Below is a guide for the expected JSON object, if in the text a field is missing fill it as null.

Expected JSON structure:
{
    \"Hack Title\": \"<title>\",
    \"Description\": \"<description>\",
    \"Main Goal\": \"<goal or purpose>\",
    \"steps(Summary)\": [
        \"<step 1>\",
        \"<step 2>\",
        // .. other steps
    ],
    \"Resources Needed\": [
        \"<resource 1>\",
        \"<resource 2>\",
        // .. other resources
    ],
    \"Expected Benefits\": [
        \"<benefit 1>\",
        \"<benefit 2>\",
        // .. other benefits
    ]
}

Don't add or remove words. Only convert the markdown to plain text. Provide your response only as a JSON object containing the structured information provided."
structured_free_desc = Prompt.new(
  name: 'Structured FREE description',
  code: 'structured_free_description',
  prompt: structured_free_description,
  system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.'
)
structured_free_desc.save

structured_premium_description = "You are an expert financial analyst with a deep understanding of financial hacks and strategies.

Hack analysis
\#{premium_analysis}
---

Your task is to structure the provided analysis into a json dictionary. The itemized objects should be saved as lists, the section titles should be dictionary keys. Below is a guide for the expected JSON object, if in the text a field is missing fill it as null.

Expected JSON structure:
{
    \"Extended Title\": \"<extended title>\",
    \"Detailed steps\": [
        {
            \"Step Title\": \"<step 1 title>\",
            \"Description\": \"<step 1 description>\",
        },
        {
            \"Step Title\": \"<step 2 title>\",
            \"Description\": \"<step 2 description>\",
        },
        // .. other steps
    ],
    \"Additional Tools and Resources\": [
        \" resource 1\",
        \" resource 2\",
        // .. other resources
    ],
    \"Case Study\": \"<case study>\"
}

Don't add or remove words. Only convert the markdown to plain text. Provide your response only as a JSON object containing the structured information provided."
structured_premium_desc = Prompt.new(
  name: 'Structured PREMIUM description',
  code: 'structured_premium_description',
  prompt: structured_premium_description,
  system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.'
)
structured_premium_desc.save

complexity_classification = "Classify the financial hack into one of the following categories, based on its complexity, accessibility, and level of financial impact:

1. *Accessible*:
   - *Description*: Simple hacks that are easy to implement by most people without requiring extensive financial knowledge or initial investment. Designed for users with any level of income and experience.
   - *Examples*: Saving small amounts regularly, reducing non-essential expenses.

2. *Intermediate*:
   - *Description*: Hacks that require some planning, basic financial knowledge, or a moderate initial investment. Useful for people with medium incomes or some experience in managing their money.
   - *Examples*: Investing while carrying debt, simple retirement planning strategies.

3. *Advanced*:
   - *Description*: More complex hacks requiring advanced financial knowledge or considerable resources. Often involve tax strategies, investment in complex assets, or sophisticated legal structures.
   - *Examples*: Utilizing REITs and advanced tax strategies to maximize returns.

## Financial hack:
---
\#{hack_description}
---

Provide your response only as a JSON object with the values as plain strings, no markdown; in the following format:

{
\"complexity\": {
        \"classification\": \"<Accessible, Intermediate or Advanced>\",
        \"explanation\": \"<A short explanation regarding the classification>\",
    },
}"
complexity = Prompt.new(
  name: 'Complexity Classification',
  code: 'complexity_classification',
  prompt: complexity_classification,
  system_prompt: 'You are a financial analyst specialized in financial hacks for users in the USA.'
)
complexity.save

financial_categories_classification = "Bellow you will be provided with a financial hack. According to the following financial categories state the applicable tags to the provided information.

## Financial categories

- `Corporate Finance`: financial activities of corporations, including investment decisions, financial management, and capital structure.
- `Investment Management`: strategies and practices of managing financial assets to maximize returns.
- `Personal Finance`: management of individual or household financial activities, including budgeting, saving, and investing.
- `Financial Markets`:  facilitate the trading of financial instruments and play a key role in the allocation of resources. Including stock market, bond market and derivative market.
- `Public Finance`: studies the role of the government in the economy, including taxation, spending, and debt management.
- `Banking and Financial Institutions`: examines banking systems and financial institutions that provide financial services to individuals and businesses.
- `Risk Management`: identifies, assesses, and prioritizes risks followed by coordinated efforts to minimize or control their impact.
- `International Finance`: focuses on the financial interactions between countries, including currency exchange, investments, and regulations.
- `Financial Planning and Analysis`: managing a company's financial health through analysis and strategic planning.
- `Fintech and Emerging Technologies`: innovative technologies and their impact on the financial industry.
- `Behavioral Finance`: investigates the psychological factors influencing investors' decisions and market dynamics.

## Financial hack:
---
\#{hack_description}
---

If there is more than one category fitting then return them all. Provide your response only as a JSON object, in the following format:

Example for more than one tag:
```json
[
  {
    \"category\": \"<category with the same name as it was listed>\",
    \"breve explanation\": \"<A short explanation regarding the classification>\"
  },
  {
    \"category\": \"<category with the same name as it was listed>\",
    \"breve explanation\": \"<A short explanation regarding the classification>\"
  },
  // ...
]
```
Example for one tag:
```json
[
  {
    \"category\": \"<category with the same name as it was listed>\",
    \"breve explanation\": \"<A short explanation regarding the classification>\"
  }
]
```"
financial_categories = Prompt.new(
  name: 'Financial Categories Classification',
  code: 'financial_categories_classification',
  prompt: financial_categories_classification,
  system_prompt: 'You are a financial analyst specialized in financial hacks for users in the USA.'
)
financial_categories.save
