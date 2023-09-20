use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-completion('Generate Raku code for a loop over a list',
        type => Whatever, model => Whatever, :$method);

## 2
ok openai-completion('Generate Raku code for a loop over a list',
        type => Whatever, model => 'gpt-3.5-turbo-instruct', :$method);

## 3
ok openai-completion('Generate Raku code for a loop over a list',
        type => 'text', model => Whatever, :$method);

## 4
ok openai-completion('Generate Raku code for a loop over a list',
        type => 'chat', model => Whatever, :$method);

## 5
dies-ok {
    openai-completion('Generate Raku code for a loop over a list', type => Whatever, model => 'gtp-blah-blah', :$method)
};

## 6
ok openai-completion('Generate Raku code for a loop over a list',
        type => Whatever, model => 'gpt-3.5-turbo', :$method);

done-testing;
