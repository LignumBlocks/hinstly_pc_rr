require 'pathname'

# paths
AI_DIR = Pathname.new(__FILE__).dirname.realpath 
print 'ai: '
puts AI_DIR
BASE_DIR = AI_DIR.parent            
print 'base: '
puts BASE_DIR
PROMPT_DIR = AI_DIR.join("prompts") 
print 'prompt: '
puts PROMPT_DIR 

# prompts
PROMPTS_TEMPLATES = {
  'HACK_VERIFICATION0' => File.join(PROMPT_DIR, "ishack", "hack_discrimination"),
  'HACK_VERIFICATION1' => File.join(PROMPT_DIR, "ishack", "hack_discrimination_medium"),
  'HACK_VERIFICATION2' => File.join(PROMPT_DIR, "ishack", "hack_discrimination_reduced"),
  'GET_QUERIES' => File.join(PROMPT_DIR, "validation", "generate_questions"),
  'VALIDATE_HACK' => File.join(PROMPT_DIR, "validation", "rag_to evaluate"),
  'DEEP_ANALYSIS' => File.join(PROMPT_DIR, "extended_description", "deep_analysis"),
  'DEEP_ANALYSIS_FREE' => File.join(PROMPT_DIR, "extended_description", "deep_analysis_free"),
  'DEEP_ANALYSIS_PREMIUM' => File.join(PROMPT_DIR, "extended_description", "deep_analysis_premium"),
  'ENRICHED_ANALYSIS_FREE' => File.join(PROMPT_DIR, "extended_description", "enriched_analysis_free"),
  'ENRICHED_ANALYSIS_PREMIUM' => File.join(PROMPT_DIR, "extended_description", "enriched_analysis_premium"),
  'STRCT_DEEP_ANALYSIS_FREE' => File.join(PROMPT_DIR, "extended_description", "structure_free"),
  'STRCT_DEEP_ANALYSIS_PREMIUM' => File.join(PROMPT_DIR, "extended_description", "structure_premium"),
  'COMPLEXITY_TAG' => File.join(PROMPT_DIR, "tagging", "complexity"),
  'CLASIFICATION_TAGS' => File.join(PROMPT_DIR, "tagging", "hack_classification"),
}
