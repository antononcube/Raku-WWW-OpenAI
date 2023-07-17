#!/usr/bin/env raku
use v6.d;

use WWW::OpenAI;

my $lang = 'Wolfram Language';

say '=' x 120;
say 'Code Writer';
say '-' x 120;

# Message response based on a (pre-)prompt
my $pre = slurp($*CWD ~ '/resources/prompts/Code-Writer.txt');

$pre .= subst('$LANG', $lang);

my $msg = q:to/END/;
Create a table listing the first 9 layers of Pascal's triangle.
END

say openai-chat-completion([system => $pre, user => $msg], max-tokens => 400, format => 'values');

#========================================================================================================================
say '=' x 120;
say 'Learn Anything Now GPT';
say '-' x 120;

# Message response based on a (pre-)prompt
my $preLAN = slurp($*CWD ~ '/resources/prompts/LAN-GPT.txt');


my $msgLAN = q:to/END/;
What are the names of the asteroids belts?
END

say openai-chat-completion([system => $preLAN, user => $msgLAN], max-tokens => 400, format => 'values');

