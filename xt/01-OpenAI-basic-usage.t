use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

plan 1;

ok openai-playground('What is the most important word in English today?');

done-testing;
