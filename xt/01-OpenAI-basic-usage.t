use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

plan *;

## 1
ok openai-playground('What is the most important word in English today?');

## 2
ok openai-playground('Generate Raku code for a loop over a list', path => 'completions', type => Whatever, model => Whatever);

## 3
ok openai-playground('Generate Raku code for a loop over a list', path => 'chat/completions', model => 'gpt-3.5-turbo');

done-testing;
