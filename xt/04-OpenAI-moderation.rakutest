use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-moderation('I want to kill them', :$method);

## 2
ok openai-playground('Python programmers are like babies', :$method);

done-testing;
