use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-playground(path => 'models', :$method);

## 2
ok openai-playground('What is the most important word in English today?', :$method);

## 3
ok openai-playground('Generate Raku code for a loop over a list', path => 'completions', type => Whatever, model => Whatever, :$method);

## 4
ok openai-playground('Generate Raku code for a loop over a list', path => 'chat/completions', model => 'gpt-3.5-turbo', :$method);

done-testing;
