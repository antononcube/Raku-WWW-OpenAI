#!/usr/bin/env raku
use v6.d;

use WWW::OpenAI;
use LLM::Prompts;

my $model = 'gpt-5.6-luna';

my $lang = 'Wolfram Language';

say '=' x 120;
say 'Code Writer';
say '-' x 120;

# Message response based on a (pre-)prompt
my $pre = llm-prompt('CodeWriterX')($lang);

my $msg = q:to/END/;
Create a table listing the first 9 layers of Pascal's triangle.
END

say openai-chat-completion([system => $pre, user => $msg], :$model, max-tokens => 2048, format => 'values');

#========================================================================================================================
say '=' x 120;
say "Explain like I'm Five (ELI5)";
say '-' x 120;

# Message response based on a (pre-)prompt
my $preELI = llm-prompt('ELI5');


my $msgELI = q:to/END/;
What are the names of the asteroids belts?
END

say openai-chat-completion([system => $preELI, user => $msgELI], :$model, max-tokens => 2048, format => 'values');

