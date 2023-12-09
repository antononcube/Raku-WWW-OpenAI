use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-create-image("racoon with perls in the style of Hannah Wilke", size => 'small', :$method);

## 2
ok openai-create-image("racoon with perls in the style of Hannah Wilke", model => 'dall-e-3', size => Whatever, :$method);

## 3
dies-ok {
    openai-create-image("racoon with perls in the style of Hannah Wilke", model => 'dall-e-3', n => 3, :$method)
};

## 4
dies-ok {
    openai-create-image("racoon with perls in the style of Hannah Wilke", model => 'dall-e-3', size => 'small', :$method)
};

## 5
dies-ok {
    openai-create-image("racoon with perls in the style of Hannah Wilke", model => 'dall-e-2', size => 'landscape', :$method)
};

## 6
dies-ok {
    openai-create-image("racoons inkblot", model => 'dall-e-3', size => '512x512', :$method)
};

done-testing;
