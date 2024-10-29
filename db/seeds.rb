# User.all.destroy_all
# Role.all.destroy_all
#
# role = Role.create!(name: 'admin')
#
# admin = User.create!(email: 'admin@hintsly.dev', password: 'password', password_confirmation: 'password')
# admin.roles << role

Prompt.all.destroy_all

prompts = [
  { name: 'Hack Discrimination Reduced', code: 'HACK_DISCRIMINATION_REDUCED', prompt: "A financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.\n
Analize the following content for financial hacks:\n---\n[{source_text}]\n---\n
The output must be a json with the following structure:\n```json
{\n    \"possible hack title\": \"<A consise title of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",\n    \"brief summary\": \"<A short description of the possible hacks in the content, regardless of if it is a valid hack under our definitions.>\",\n    \"justification\": \"<Explanation about whether the content includes a valid financial hack>\",\n    \"is_a_hack\": \"<Boolean true or false, about whether the content includes a valid financial hack>\"\n}\n```\n
Scan the content for financial advice or strategies. Evaluate if any hack can be extracted from it. If the content is not about financial advices \"is_a_hack\" must be false", system_prompt: 'You are an AI financial analyst tasked with classifying content related to financial strategies.' },

  { name: 'Generate queries for hack', code: 'GENERATE_QUERIES', prompt: "Given the following financial 'hack', generate a set of [{num_queries}] relevant queries that allow verifying the validity of the hack. The queries will be used on official financial websites to search for information that can validate or refute the techniques or suggestions of the hack. Make sure to:\n
- Use key terms from the hack title and summary when possible.\n- Keep the queries concise and direct, without unnecessary filler words.\n- Formulate the queries in a way that they seek specific information related to the validity of the hack.\n
The validation should check about legality, risks and temporal relevance.\n
Financial hack title:\n[{hack_title}]\n---\nFinancial hack summary:\n[{hack_summary}]\n
Provide your response only as a JSON object containing a list of the relevant queries, in the following format:\n
{\n    \"queries\": [ ... ]\n}\n", system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.' },

  { name: 'Hack validation', code: 'HACK_VALIDATION', prompt: "Here is an extract of relevant context from different web pages:\n
  ---\n[{chunks}]\n  ---\n
Given the provided search context, please validate or refute the following financial hack according to this factors:\nA financial hack is a practical strategy or technique that helps individuals optimize their finances, save money, increase income, or improve their overall economic situation. Hacks range from easily accessible tips to sophisticated strategies used by high-net-worth individuals.\n - Legality and Risks: Must comply with legal standards, highlighting legal implications, tax loopholes, and ethical issues.\n - Temporal Relevance: Must be suitable for the current economic context.\n
Financial hack title:\n[{hack_title}]\n---\nFinancial hack summary:\n[{hack_summary}]\n
If the information is not enough to emit an opinion about the validity or you are unsure answer Invalid.\nProvide your response only as a JSON object containing the analysis, in the following format:\n
{\n    \"validation analysis\": \"<Deep analysis about the validity of the hack, according to the factors above>\",\n    \"validation status\": \"<Valid, Invalid>\"\n  }", system_prompt: 'You are an AI financial analyst tasked with accepting or refusing the validity of a financial hack.' },

  { name: 'Initial FREE description', code: 'FREE_DESCRIPTION', prompt: "You are an expert financial analyst with a deep understanding of financial hacks and strategies.\nThis is a financial hack information.
Hack Title:\n[{hack_title}]\n---\nSummary:\n[{hack_summary}]\n---\nSource Text of the Hack:\n[{original_text}]\n---\n
Your task is to provide a comprehensive analysis of the financial hack described above, adhering to the following guidelines. The result will be read directly by a user, keep that in mind. The analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Hack Title:\n  Provide a concise and engaging title for the hack.\n
## Description:\n  Summarize the hack's concept and benefits in 2-3 sentences. Highlight how the hack improves the user's financial situation or habits. Make it concise and objective\n
## Main Goal:\n  Clearly state the hack's primary purpose in one sentence.\n
## Steps for Implementation (Summary):\n  List 3-5 concise, actionable steps for the user to implement the hack.\n  Ensure the steps are clear and simple enough for any user to follow without advanced knowledge.\n
## Resources Needed:\n  List the essential tools, apps, or bank accounts necessary to implement the strategy effectively (e.g., specific apps, online banks, calculators).\n
## Expected Benefits:\n  Briefly outline the financial or psychological benefits of applying the hack (e.g., improved savings discipline, accelerated debt payoff, reduced stress, etc.).", system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.' },

  { name: 'Initial PREMIUM description', code: 'PREMIUM_DESCRIPTION', prompt: "You are an expert financial analyst with a deep understanding of financial hacks and strategies.\n
Hack Title:\n[{hack_title}]\n---\nSummary:\n[{hack_summary}]\n---\nSource Text of the Hack:\n[{original_text}]\n---\nSimplified analysis\n[{analysis}]\n---\n
Your task is to provide a comprehensive analysis of the financial hack described above, adhering to the following guidelines. The result will be read directly by a user, keep that in mind.\nYour Analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars. Adapt examples and terminology to the user's region or state within the USA. Align with current laws and regulations in the USA and specific states.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Extended Title:\n  Provide an extended version of the title in the `Simplified analysis` to reflect the in-depth content.\n
## Detailed Steps for Implementation:\n  Offer an extended breakdown of each step listed in the `Simplified analysis`, including additional details and context to optimize the hack.\n  Ensure the steps are clear for any user to follow without advanced knowledge.\n  Include personalized tips, tricks, and insights to help the users tailor the strategy to their personal finances.\n  Explain advanced considerations that could help users maximize the hack.\n
## Additional Tools and Resources:\n  Suggest advanced apps, bank accounts that users can use to enhance the strategy.\n  Provide recommendations for tools that offer more complex tracking, customization, or integration with other financial plans (e.g., debt payoff calculators, investment tools, detailed budgeting systems).\n
## Case Study Outline:\n  Provide a brief outline for a realistic case study that demonstrates how a hypothetical user applies the hack and benefits from it.", system_prompt: 'You are a financial analyst specializing in creating financial hacks for users in the USA.' },

  { name: 'Enrich Free description', code: 'ENRICH_FREE_DESCRIPTION', prompt: "Your task is to analyze each section in the hack description and extend it with the information provided in the context.\n
Here is an extract of relevant context from different web pages:\n[{chunks}]\n---\nHack description:\n[{previous_analysis}]\n---\n
Analyze each section in the hack description and expand it with the information provided. The analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars.\nMaintain the structure and the speech style from the `Hack description`. The title must be concise and engaging, don't change it if it is not necessary.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Hack Title:\n  Concise and engaging title for the hack.\n
## Description:\n  Summarized hack's concept and benefits. Objective analysis of how the hack improves the user's financial situation or habits.\n
## Main Goal:\n  Hack's primary purpose.\n
## Steps for Implementation (Summary):\n  3-5 concise, actionable steps to implement the hack. Clear and simple enough for any user to follow without advanced knowledge.\n
## Resources Needed:\n  List of the essential tools, apps, or bank accounts necessary to implement the strategy effectively.\n
## Expected Benefits:\n  Outline of the benefits of applying the hack.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Enrich Premium description', code: 'ENRICH_PREMIUM_DESCRIPTION', prompt: "Your task is to analyze each section in the hack description and extend it with the information provided in the context.\n
Here is an extract of relevant context from different web pages:\n[{chunks}]\n---\nSimplified analysis:\n[{free_analysis}]\n---\nHack description:\n[{previous_analysis}]\n---\n
Analyze each section in the hack description and expand it with the information provided.\nThe analysis should be deeply detailed, structured, and articulate, providing the user with a clear understanding of this financial hack and its implications. Only answer about the indications in the guideline. The style should be in 2nd person, speaking to a user. Never mention 'this hack', substitute that for a reference to the title or with 'this idea', 'this technique' and similars.\nMaintain the structure and the speech style from the `Hack description`. The title must be concise and engaging, don't change it if it is not necessary.\n
The output format must not include bold (\"**\") or italic (\"*\"). And the format should follow this structure and guidelines.\n
# Extended Title:\n  Extended version of the title in the `Simplified analysis` to reflect the in-depth content.\n
## Detailed Steps for Implementation:\n  Extended breakdown of each step listed in the `Simplified analysis`, including additional details and context to optimize the hack. The steps must br clear for any user to follow without advanced knowledge. With advanced considerations that could help users maximize the benefits of the hack.\n
## Additional Tools and Resources:\n  Advanced apps, bank accounts and services that users can use to enhance the strategy. Recommendations for tools that offer more complex tracking, customization, or integration with other financial plans (e.g., debt payoff calculators, investment tools, detailed budgeting systems).\n
## Case Study Outline:\n  Brief outline for a realistic case study that demonstrates how a hypothetical user applies the hack and benefits from it.", system_prompt: 'You are an expert financial analyst with a deep understanding of financial hacks and strategies.' },

  { name: 'Structured FREE description', code: 'STRUCTURED_FREE_DESCRIPTION', prompt: "Hack analysis
#[{analysis}]\n---\nYour task is to structure the provided analysis into a json dictionary. The itemized objects should be saved as lists, the section titles should be dictionary keys. Below is a guide for the expected JSON object, if in the text a field is missing fill it as null.\n
Expected JSON structure:\n{\n    \"Hack Title\": \"<title>\",\n    \"Description\": \"<description>\",\n    \"Main Goal\": \"<goal or purpose>\",\n    \"steps(Summary)\": [\n        \"<step 1>\",\n        \"<step 2>\",\n        // .. other steps
    ],\n    \"Resources Needed\": [\n        \"<resource 1>\",\n        \"<resource 2>\",\n        // .. other resources
    ],\n    \"Expected Benefits\": [\n        \"<benefit 1>\",\n        \"<benefit 2>\",\n        // .. other benefits
    ]\n}\n
Don't add or remove words. Only convert the markdown to plain text. Provide your response only as a JSON object containing the structured information provided.", system_prompt: 'You are an expert at text processing, in particular, financial related information.' },

  { name: 'Structured PREMIUM description', code: 'STRUCTURED_PREMIUM_DESCRIPTION', prompt: "Your task is to structure the provided analysis into a json dictionary. \n
Hack analysis:\n[{analysis}]\n---\n
The itemized objects should be saved as lists, the section titles should be dictionary keys. Below is a guide for the expected JSON object, if in the text a field is missing fill it as null.\n
Expected JSON structure:\n{\n    \"Extended Title\": \"<extended title>\",
    \"Detailed steps\": [\n        {\n            \"Step Title\": \"<step 1 title>\",\n            \"Description\": \"<step 1 description>\",\n        },\n        {\n            \"Step Title\": \"<step 2 title>\",\n            \"Description\": \"<step 2 description>\",\n        },\n        // .. other steps\n    ],
    \"Additional Tools and Resources\": [\n        \" resource 1\",\n        \" resource 2\",\n        // .. other resources\n    ],\n    \"Case Study\": \"<case study>\"\n}\n
Don't add or remove words. Only convert the markdown to plain text. Provide your response only as a JSON object containing the structured information provided.", system_prompt: 'You are an expert at text processing, in particular, financial related information.' },

  { name: 'Complexity Classification', code: 'COMPLEXITY_CLASSIFICATION', prompt: "Classify the financial hack into one of the following categories, based on its complexity, accessibility, and level of financial impact:\n
1. *Accessible*:\n   - *Description*: Simple hacks that are easy to implement by most people without requiring extensive financial knowledge or initial investment. Designed for users with any level of income and experience.\n   - *Examples*: Saving small amounts regularly, reducing non-essential expenses.\n
2. *Intermediate*:\n   - *Description*: Hacks that require some planning, basic financial knowledge, or a moderate initial investment. Useful for people with medium incomes or some experience in managing their money.\n   - *Examples*: Investing while carrying debt, simple retirement planning strategies.\n
3. *Advanced*:\n   - *Description*: More complex hacks requiring advanced financial knowledge or considerable resources. Often involve tax strategies, investment in complex assets, or sophisticated legal structures.\n   - *Examples*: Utilizing REITs and advanced tax strategies to maximize returns.\n
## Financial hack:\n---\n[{hack_description}]\n---\n
Provide your response only as a JSON object with the values as plain strings, no markdown; in the following format:\n```json\n
{\n    \"category\": \"<Accessible, Intermediate or Advanced>\",\n    \"explanation\": \"<A short explanation regarding the classification>\",\n}\n```", system_prompt: 'You are a financial analyst specialized in financial hacks for users in the USA.' },

  { name: 'Financial Categories Classification', code: 'FINANCIAL_CLASSIFICATION', prompt: "Bellow you will be provided with a financial hack. According to the following financial categories state the applicable tags to the provided information.\n
## Financial categories:\n
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
- `Behavioral Finance`: investigates the psychological factors influencing investors' decisions and market dynamics.\n
## Financial hack:\n---\n[{hack_description}]\n---\n\nIf there is more than one category fitting then return them all. Provide your response only as a JSON object, in the following format:\n
Example for more than one tag:\n```json
[\n  {\n    \"category\": \"<category with the same name as it was listed>\",\n    \"explanation\": \"<A short explanation regarding the classification>\"\n  },\n  {\n    \"category\": \"<category with the same name as it was listed>\",\n\"breve explanation\": \"<A short explanation regarding the classification>\"\n  },\n  // ...\n]\n```
Example for one tag:\n```json
[\n  {\n    \"category\": \"<category with the same name as it was listed>\",\n    \"explanation\": \"<A short explanation regarding the classification>\"\n  }\n]\n```", system_prompt: 'You are a financial analyst specialized in financial hacks for users in the USA.' },

  { name: 'Generic Single Category Classification', code: 'GENERIC_SINGLE_CATEGORY_CLASSIFICATION', prompt: "Classify the financial hack into one of the following categories, based on [{based_on}]:\n
[{explained_categories}]\n
## Financial hack:\n---\n\[{hack_description}]\n---\n
Provide your response only as a JSON object with the values as plain strings, no markdown; in the following format:\n```json\n
{\n    \"category\": \"<[{categories}]>\",\n    \"explanation\": \"<A short explanation regarding the classification>\",\n}\n```", system_prompt: 'You are a financial analyst specialized in financial hacks for users in the USA.' },

  { name: 'Generic Multi-Category Classification', code: 'GENERIC_MULTI_CATEGORY_CLASSIFICATION', prompt: "Bellow you will be provided with a financial hack. According to the following [{class_name}] categories, state the applicable tags to the provided information.\n
##[{class_name}] categories:
[{explained_categories}]\n
## Financial hack:\n---\n\[{hack_description}]\n---\n\nIf there is more than one category fitting then return them all. Provide your response only as a JSON object, in the following format:\n
Example for more than one tag:\n```json
[\n  {\n    \"category\": \"<category with the same name as it was listed>\",\n    \"explanation\": \"<A short explanation regarding the classification>\"\n  },\n  {\n    \"category\": \"<category with the same name as it was listed>\",\n\"breve explanation\": \"<A short explanation regarding the classification>\"\n  },\n  // ...\n]\n```
Example for one tag:\n```json
[\n  {\n    \"category\": \"<category with the same name as it was listed>\",\n    \"explanation\": \"<A short explanation regarding the classification>\"\n  }\n]\n```", system_prompt: 'You are a financial analyst specialized in financial hacks for users in the USA.' },

  { name: 'Scrap Links',
    code: 'SCRAP_LINKS',
    system_prompt: 'You are an expert in web scraping and data analysis, assisting users in extracting information from websites and helping to identify valuable links based on the content of web pages.',
    prompt: "Given a string containing HTML code, please extract and return a maximum of the 3 more relevant links related to a specific topic that I will provide,
      You must return them only if they are related but never more than 3 and if it's impossible to find any, dont give any explanation

      Do not include any HTML elements or JavaScript code in your response; focus solely on the most important links concerning the requested topic.

      Only extract links that could contain relevant ideas or information about the given topic and return them in a JSON format as follows: { \"links\": [ ... ] }.

      Please do not include links or any unrelated text that does not convey a specific idea.The topic is: #[{query}] and here is the text: #[{content}]" }

]
prompts.each { |prompt| Prompt.create(prompt) }

ValidationSource.all.destroy_all
validation_sources = [
  { name: 'Finance Consumer',
    url_query: 'https://search.consumerfinance.gov/search?utf8=%E2%9C%93&affiliate=cfpb&query=' },
  { name: 'Investopedia', url_query: 'https://www.investopedia.com/search?q=' },
  { name: 'Forbes', url_query: 'https://www.forbes.com/search/?q=' },
  { name: 'Bloomberg', url_query: 'https://www.bloomberg.com/search?query=' },
  { name: 'Wall Street Journal', url_query: 'https://www.wsj.com/search?query=' },
  { name: 'Money', url_query: 'https://money.com/search/?q=' },
  { name: 'MarketWatch', url_query: 'https://www.marketwatch.com/search?q=' },
  { name: 'The Balance', url_query: 'https://www.thebalancemoney.com/search?q=' },
  { name: 'Kiplinger', url_query: 'https://www.kiplinger.com/search?searchTerm=' },
  { name: 'Bankrate', url_query: 'https://www.bankrate.com/search/?q=' },
  { name: 'Morningstar', url_query: 'https://www.morningstar.com/search?query=' },
  { name: 'NerdWallet', url_query: 'https://www.nerdwallet.com/search/results?query=' },
  { name: 'Money Under 30', url_query: 'https://www.moneyunder30.com/?s=' },
  { name: 'GoBankingRates', url_query: 'https://www.gobankingrates.com/search/?q=' },
  { name: 'US News Money', url_query: 'https://money.usnews.com/search?q=' },
  { name: 'Reuters', url_query: 'https://www.reuters.com/site-search/?query=' },
  { name: 'The Street', url_query: 'https://www.thestreet.com/search?query=' },
  { name: 'Financial Samurai', url_query: 'https://www.financialsamurai.com/?s=' },
  { name: 'CNN', url_query: 'https://www.cnn.com/search?q=' },
  { name: 'Benzinga', url_query: 'https://www.benzinga.com/search?q=' },
  { name: 'Money Crashers', url_query: 'https://www.moneycrashers.com/search/' },
  { name: 'Seeking Alpha', url_query: 'https://seekingalpha.com/search?q=' },
  { name: 'Barron\'s', url_query: 'https://www.barrons.com/search?keyword=' },
  { name: 'Mr. Money Mustache', url_query: 'https://www.mrmoneymustache.com/?s=' },
  { name: 'Get Rich Slowly', url_query: 'https://www.getrichslowly.org/?s=' },
  { name: 'Wallet Hacks', url_query: 'https://wallethacks.com/?s=' },
  { name: 'Afford Anything', url_query: 'https://affordanything.com/?s=' },
  { name: 'Business Insider', url_query: 'https://www.businessinsider.com/answers#' },
  { name: 'Investors', url_query: 'https://www.investors.com/search-results/?query=' },
  { name: 'Financial Times', url_query: 'https://www.ft.com/search?q=' },
  { name: 'Wise Bread', url_query: 'https://www.wisebread.com/search/node/' },
  { name: 'Value Penguin', url_query: 'https://www.valuepenguin.com/search/' },
  { name: 'My Money', url_query: 'https://search.usa.gov/search?affiliate=mymoney&query=' },
  { name: 'FINRA Foundation', url_query: 'https://www.finrafoundation.org/search?search=' },
  { name: 'Operation Hope', url_query: 'https://operationhope.org/?s=' },
  { name: 'NFCC', url_query: 'https://www.nfcc.org/?s=' },
  { name: 'Money Management', url_query: 'https://www.moneymanagement.org/search?query=' },
  { name: 'InCharge', url_query: 'https://www.incharge.org/?s=' },
  { name: 'Salt Money', url_query: 'https://saltmoney.org/?s=' },
  { name: 'NGPF', url_query: 'https://www.ngpf.org/search/?q=' },
  { name: 'United Way', url_query: 'https://www.unitedway.org/search?q=' },
  { name: 'Green Path', url_query: 'https://www.greenpath.com/?s=' },
  { name: 'Center for Financial Inclusion', url_query: 'https://www.centerforfinancialinclusion.org/?s=' },
  { name: 'Bank On', url_query: 'https://joinbankon.org/?s=' },
  { name: 'BestPrep', url_query: 'https://bestprep.org/?s=' },
  { name: 'NYC Gov', url_query: 'https://www.nyc.gov/home/search/index.page?search-terms=' },
  { name: 'FinHealth Network', url_query: 'https://finhealthnetwork.org/?s=' },
  { name: 'Mission Asset Fund', url_query: 'https://www.missionassetfund.org/?s=' },
  { name: 'NAPFA', url_query: 'https://www.napfa.org/search?q=' },
  { name: 'AICPA CIMA', url_query: 'https://www.aicpa-cima.com/search/' },
  { name: 'Financial Planning Association', url_query: 'https://www.financialplanningassociation.org/search?keyword=' },
  { name: 'Consumer Federation', url_query: 'https://consumerfed.org/search/?search=' },
  { name: 'SEC', url_query: 'https://secsearch.sec.gov/search?query=' },
  { name: 'IRS', url_query: 'https://www.irs.gov/site-index-search?search=' },
  { name: 'Federal Reserve', url_query: 'https://www.fedsearch.org/board_public/search?text=' },
  { name: 'US Treasury', url_query: 'https://search.treasury.gov/search?affiliate=treas&query=' },
  { name: 'FinCEN', url_query: 'https://search.usa.gov/search?affiliate=fincen&publication_date=latest&query=' },
  { name: 'OCC', url_query: 'https://www.occ.gov/search.html?q=' },
  { name: 'FTC', url_query: 'https://search.ftc.gov/search?affiliate=ftc_prod&query=' },
  { name: 'BIS', url_query: 'https://www.bis.org/search/index.htm?globalset_q=' },
  { name: 'CFTC', url_query: 'https://www.cftc.gov/solr-search/content?keys=' },
  { name: 'NFA', url_query: 'https://www.nfa.futures.org/search.html#stq=' },
  { name: 'FINRA', url_query: 'https://www.finra.org/search?search_api_fulltext=' },
  { name: 'Social Security', url_query: 'https://search.ssa.gov/search?affiliate=ssa&query=' },
  { name: 'Fiscal Treasury', url_query: 'https://search.usa.gov/search?affiliate=fiscal&query=' },
  { name: 'GSA', url_query: 'https://search.gsa.gov/search?affiliate=gsa.gov&query=' },
  { name: 'EXIM Bank', url_query: 'https://search.exim.gov/search?affiliate=exim&query=' },
  { name: 'OFAC', url_query: 'https://search.usa.gov/search?affiliate=ofac&query=' },
  { name: 'SBA', url_query: 'https://www.sba.gov/search?query=' },
  { name: 'PBGC', url_query: 'https://www.pbgc.gov/search-all?f%5B0%5D=content_type%3Apage&key=' },
  { name: 'GAO', url_query: 'https://www.gao.gov/search?keyword=' },
  { name: 'NCUA', url_query: 'https://ncua.gov/search?q=' },
  { name: 'OFR', url_query: 'https://search.usa.gov/search?affiliate=ofr&query=' },
  { name: 'White House', url_query: 'https://www.whitehouse.gov/?s=' },
  { name: 'USAGov', url_query: 'https://search.usa.gov/search?affiliate=usagov_all_gov&query=' },
  { name: 'TreasuryDirect', url_query: 'https://search.usa.gov/search?affiliate=treasurydirect&query=' },
  { name: 'Department of Labor', url_query: 'https://search.usa.gov/search/docs?affiliate=www.dol.gov-ebsa&query=' },
  { name: 'FHFA', url_query: 'https://www.fhfa.gov/search/node?keys=' },
  { name: 'FCC', url_query: 'https://www.fcc.gov/search/#q=' },
  { name: 'NIST', url_query: 'https://www.nist.gov/search?s=' },
  { name: 'CMS', url_query: 'https://www.cms.gov/search/cms?keys=' },
  { name: 'housingandurbandevelopment',
    url_query: 'https://search.usa.gov/search?affiliate=housingandurbandevelopment&query=' },
  { name: 'PFM', url_query: 'https://www.pfm.com/newsroom/search-results?indexCatalogue=site-search&searchQuery=' },
  { name: 'BLS', url_query: 'https://data.bls.gov/search/query/results?q=' },
  { name: 'CENSUS', url_query: 'https://www.census.gov/search-results.html?q=' },
  { name: 'COMMERCE', url_query: 'https://search.commerce.gov/search?affiliate=www.commerce.gov&query=' },
  { name: 'STUDENTAID', url_query: 'https://studentaid.gov/help-center/answers/search?tab=all&page=1&q=' },
  { name: 'CATALOG', url_query: 'https://catalog.data.gov/dataset?q=' },
  { name: 'ED', url_query: 'https://www.ed.gov/search?search_api_fulltext=' },
  { name: 'SIPC', url_query: 'https://www.sipc.org/search?query=' }
]

validation_sources.each { |source| ValidationSource.create(source) }

# Crear clasificaciones
Clasification.all.destroy_all
HackCategoryRel.all.destroy_all
Category.all.destroy_all

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
