use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';
#my $model = 'gpt-3.5-turbo';
my $model = 'text-curie-001';
my $max-tokens = 120;

plan *;

## 1
ok openai-find-textual-answer("racoon with perls in the style of Hannah Wilke",
        ['What style?', 'What about?'],
        :$max-tokens, :$model, :$method);

## 2
my $text2 = 'make a classifier with the method RandomForest over the dataset dfTitanic; show accuracy and recall';
my @questions = ['which method?', 'which dataset?', 'what metrics to display?'];
ok openai-find-textual-answer($text2, @questions, :$max-tokens, :$model, :$method);

## 3
ok openai-find-textual-answer($text2, @questions, request => 'answer the questions', :$max-tokens, :$model, :$method);

## 4
ok openai-find-textual-answer($text2, 'Which dataset?', model => 'gpt-3.5-turbo-0301', :$max-tokens, :$method);

## 5
isa-ok openai-find-textual-answer($text2, @questions,
        model => 'gpt-3.5-turbo-0301',
        :pairs,
        :$max-tokens,
        :$method).all ~~ Pair,
        True;

done-testing;
