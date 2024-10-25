User.all.destroy_all
Role.all.destroy_all

role = Role.create!(name: 'admin')

admin = User.create!(email: 'admin@hintsly.dev', password: 'password', password_confirmation: 'password')
admin.roles << role

prompts = [
  { name: 'Hack Discrimination Reduced', code: 'HACK_DISCRIMINATION_REDUCED', prompt: "A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.\n
Analize the following content for financial hacks.\n
Analize the following content for financial hacks:\n---\n[{source_text}]\n---\n
The output must be a json with the following structure:\n```json
{{\n    \"possible hack title\": \"<A consise title of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",\n    \"brief summary\": \"<A short description of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",\n    \"justification\": \"<Explanation about whether the content includes a valid financial hack>\",\n    \"is_a_hack\": \"<Boolean true or false, about whether the content includes a valid financial hack>\"\n}}\n```", system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.' },

  { name: 'Generate queries for hack', code: 'GENERATE_QUERIES', prompt: "Given the following financial 'hack', generate a set of [{num_queries}] relevant queries that allow verifying the validity of the hack. The queries will be used on official financial websites to search for information that can validate or refute the techniques or suggestions of the hack. Make sure to:\n
- Use key terms from the hack title and summary when possible.\n- Keep the queries concise and direct, without unnecessary filler words.\n- Formulate the queries in a way that they seek specific information related to the validity of the hack.\n
The validation should check about legality, risks and temporal relevance.\n
Financial hack title:\n#[{hack_title}]\n---\nFinancial hack summary:\n#[{hack_summary}]\n
Provide your response only as a JSON object containing a list of the relevant queries, in the following format:\n
{\n    \"queries\": [ ... ]\n}\n", system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.' },

  { name: 'Hack validation', code: 'HACK_VALIDATION', prompt: "\"\"\"Here is an extract of relevant context from different web pages:\n
  ---\n  #[{chunks}]\n  ---\n
  Given the provided search context, please validate or refute the following financial hack according to this factors:\n  A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.\n  - Legality and Risks: Must comply with legal standards, highlighting legal implications, tax loopholes, and ethical issues.\n  - Temporal Relevance: Must be suitable for the current economic context.\n
  Financial hack title:\n  #[{hack_title}]\n  ---\n  Financial hack summary:\n  #[{hack_summary}]\n
  If the information is not enough to emit an opinion about the validity or you are unsure answer Invalid.\n  Provide your response only as a JSON object containing the analysis, in the following format:\n
  {\n      \"validation analysis\": \"<Deep analysis about the validity of the hack, according to the factors above>\",\n      \"validation status\": \"<Valid, Invalid>\"\n  }\n  \"\"\"", system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.' },

  { name: 'Initial FREE description', code: 'FREE_DESCRIPTION', prompt: "Hack Title:\n#[{hack_title}]\n---\nSummary:\n#[{hack_summary}]\n---
Source Text of the Hack:\n#[{original_text}]\n---\nYour task is to provide a comprehensive analysis of the financial hack described above, adhering to the following guidelines. The result will be read directly by a user, keep that in mind. The analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Hack Title:\n  Provide a concise and engaging title for the hack.\n
## Description:\n  Summarize the hack's concept and benefits in 2-3 sentences. Highlight how the hack improves the user's financial situation or habits. Make it concise and objective

## Main Goal:\n  Clearly state the hack's primary purpose in one sentence.\n
## Steps for Implementation (Summary):\n  List 3-5 concise, actionable steps for the user to implement the hack.\n  Ensure the steps are clear and simple enough for any user to follow without advanced knowledge.\n
## Resources Needed:\n  List the essential tools, apps, or bank accounts necessary to implement the strategy effectively (e.g., specific apps, online banks, calculators).\n
## Expected Benefits:\n  Briefly outline the financial or psychological benefits of applying the hack (e.g., improved savings discipline, accelerated debt payoff, reduced stress, etc.).", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Enrich Free description', code: 'ENRICH_FREE_DESCRIPTION', prompt: "Here is an extract of relevant context from different web pages:\n#[{chunks}]\n---\nHack description:\n#[{previous_analysis}]\n---\nYour task is to analyze each section in the hack description and extend it with the information provided in the context.\nThe analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.\nMaintain the structure and the speech style from the `Hack description`. The title must be concise and engaging, don't change it if it is not necessary.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Hack Title:\n  Concise and engaging title for the hack.\n## Description:\n  Summarized hack's concept and benefits. Objective analysis of how the hack improves the user's financial situation or habits.\n## Main Goal:\n  Hack's primary purpose.\n## Steps for Implementation (Summary):\n  3-5 concise, actionable steps to implement the hack. Clear and simple enough for any user to follow without advanced knowledge.\n## Resources Needed:\n  List of the essential tools, apps, or bank accounts necessary to implement the strategy effectively.\n## Expected Benefits:\n  Outline of the benefits of applying the hack.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Enrich Premium description', code: 'ENRICH_PREMIUM_DESCRIPTION', prompt: "Here is an extract of relevant context from different web pages:\n#[{chunks}]\n---\nSimplified analysis
#[{free_analysis}]\n---\nHack description:\n#[{previous_analysis}]\n---\nYour task is to analyze each section in the hack description and extend it with the information provided in the context above.\nThe analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.\nMaintain the structure and the speech style from the `Hack description`. The title must be concise and engaging, don't change it if it is not necessary.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Extended Title:\n  Extended version of the title in the `Simplified analysis` to reflect the in-depth content.\n## Detailed Steps for Implementation:\n  Extended breakdown of each step listed in the `Simplified analysis`, including additional details and context to optimize the hack. The steps must br clear for any user to follow without advanced knowledge. With advanced considerations that could help users maximize the benefits of the hack.\n## Additional Tools and Resources:\n  Advanced apps, bank accounts and services that users can use to enhance the strategy. Recommendations for tools that offer more complex tracking, customization, or integration with other financial plans (e.g., debt payoff calculators, investment tools, detailed budgeting systems).\n## Case Study Outline:\n  Brief outline for a realistic case study that demonstrates how a hypothetical user applies the hack and benefits from it.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Structured FREE description', code: 'STRUCTURED_FREE_DESCRIPTION', prompt: "Hack analysis
#[{analysis}]\n---\nYour task is to structure the provided analysis into a json dictionary. The itemized objects should be saved as lists, the section titles should be dictionary keys. Below is a guide for the expected JSON object, if in the text a field is missing fill it as null.\n
Expected JSON structure:\n{\n    \"Hack Title\": \"<title>\",\n    \"Description\": \"<description>\",\n    \"Main Goal\": \"<goal or purpose>\",\n    \"steps(Summary)\": [\n        \"<step 1>\",\n        \"<step 2>\",\n        // .. other steps
    ],\n    \"Resources Needed\": [\n        \"<resource 1>\",\n        \"<resource 2>\",\n        // .. other resources
    ],\n    \"Expected Benefits\": [\n        \"<benefit 1>\",\n        \"<benefit 2>\",\n        // .. other benefits
    ]\n}\n
Don't add or remove words. Only convert the markdown to plain text. Provide your response only as a JSON object containing the structured information provided.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Structured PREMIUM description', code: 'STRUCTURED_PREMIUM_DESCRIPTION', prompt: "Hack analysis
#[{analysis}]\n---\nYour task is to structure the provided analysis into a json dictionary. The itemized objects should be saved as lists, the section titles should be dictionary keys. Below is a guide for the expected JSON object, if in the text a field is missing fill it as null.\n
Expected JSON structure:\n{\n    \"Extended Title\": \"<extended title>\",\n    \"Detailed steps\": [\n        {\n            \"Step Title\": \"<step 1 title>\",\n            \"Description\": \"<step 1 description>\",\n        },\n        {\n            \"Step Title\": \"<step 2 title>\",\n            \"Description\": \"<step 2 description>\",\n        },\n        // .. other steps
    ],\n    \"Additional Tools and Resources\": [\n        \" resource 1\",\n        \" resource 2\",\n        // .. other resources
    ],\n    \"Case Study\": \"<case study>\"\n}\n
Don't add or remove words. Only convert the markdown to plain text. Provide your response only as a JSON object containing the structured information provided.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Initial PREMIUM description', code: 'PREMIUM_DESCRIPTION', prompt: "Hack Title:\n#[{hack_title}]\n---\nSummary:\n#[{hack_summary}]\n---
Source Text of the Hack:\n#[{original_text}]\n---\nSimplified analysis
#[{analysis}]\n---\nYour task is to provide a comprehensive analysis of the financial hack described above, adhering to the following guidelines. The result will be read directly by a user, keep that in mind.\nYour Analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Extended Title:\n  Provide an extended version of the title in the `Simplified analysis` to reflect the in-depth content.\n## Detailed Steps for Implementation:\n  Offer an extended breakdown of each step listed in the `Simplified analysis`, including additional details and context to optimize the hack.\n  Ensure the steps are clear for any user to follow without advanced knowledge.\n  Include personalized tips, tricks, and insights to help the users tailor the strategy to their personal finances.\n  Explain advanced considerations that could help users maximize the hack.\n## Additional Tools and Resources:\n  Suggest advanced apps, bank accounts that users can use to enhance the strategy.\n  Provide recommendations for tools that offer more complex tracking, customization, or integration with other financial plans (e.g., debt payoff calculators, investment tools, detailed budgeting systems).\n## Case Study Outline:\n  Provide a brief outline for a realistic case study that demonstrates how a hypothetical user applies the hack and benefits from it.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' }
]
prompts.each { |prompt| Prompt.create(prompt) }

validation_sources = [
  { name: 'Finance Consumer',
    url_query: 'https://search.consumerfinance.gov/search?utf8=%E2%9C%93&affiliate=cfpb&query=' },
  { name: 'Investopedia', url_query: 'https://www.investopedia.com/search?q=' }
]

validation_sources.each { |source| ValidationSource.create(source) }

# Crear clasificaciones
financial_classification = Clasification.create(name: 'Financial')
complexity_classification = Clasification.create(name: 'Complexity')

# Crear categorías para Financial_categories
Category.create([
                  { name: 'Corporate Finance',
                    description: 'Financial activities of corporations, including investment decisions, financial management, and capital structure.', clasification: financial_classification },
                  { name: 'Investment Management',
                    description: 'Strategies and practices of managing financial assets to maximize returns.', clasification: financial_classification },
                  { name: 'Personal Finance',
                    description: 'Management of individual or household financial activities, including budgeting, saving, and investing.', clasification: financial_classification },
                  { name: 'Financial Markets',
                    description: 'Facilitate the trading of financial instruments and play a key role in the allocation of resources. Including stock market, bond market, and derivative market.', clasification: financial_classification },
                  { name: 'Public Finance',
                    description: 'Studies the role of the government in the economy, including taxation, spending, and debt management.', clasification: financial_classification },
                  { name: 'Banking and Financial Institutions',
                    description: 'Examines banking systems and financial institutions that provide financial services to individuals and businesses.', clasification: financial_classification },
                  { name: 'Risk Management',
                    description: 'Identifies, assesses, and prioritizes risks followed by coordinated efforts to minimize or control their impact.', clasification: financial_classification },
                  { name: 'International Finance',
                    description: 'Focuses on the financial interactions between countries, including currency exchange, investments, and regulations.', clasification: financial_classification },
                  { name: 'Financial Planning and Analysis',
                    description: "Managing a company's financial health through analysis and strategic planning.", clasification: financial_classification },
                  { name: 'Fintech and Emerging Technologies',
                    description: 'Innovative technologies and their impact on the financial industry.', clasification: financial_classification },
                  { name: 'Behavioral Finance',
                    description: "Investigates the psychological factors influencing investors' decisions and market dynamics.", clasification: financial_classification }
                ])

# Crear categorías para Complexity
Category.create([
                  { name: 'Accessible',
                    description: 'Simple hacks that are easy to implement by most people without requiring extensive financial knowledge or initial investment. Designed for users with any level of income and experience. Examples: Saving small amounts regularly, reducing non-essential expenses.', clasification: complexity_classification },
                  { name: 'Intermediate',
                    description: 'Hacks that require some planning, basic financial knowledge, or a moderate initial investment. Useful for people with medium incomes or some experience in managing their money. Examples: Investing while carrying debt, simple retirement planning strategies.', clasification: complexity_classification },
                  { name: 'Advanced',
                    description: 'More complex hacks requiring advanced financial knowledge or considerable resources. Often involve tax strategies, investment in complex assets, or sophisticated legal structures. Examples: Utilizing REITs and advanced tax strategies to maximize returns.', clasification: complexity_classification }
                ])
