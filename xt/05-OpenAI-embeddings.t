use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
my $query = 'make a classifier with the method RandomForeset over the data dfTitanic; show precision and accuracy; plot True Positive Rate vs Positive Predictive Value.';

is openai-embeddings($query, format => "values", :$method).WHAT ∈ (Positional, Seq), True;

## 2
my @queries = [
        'make a classifier with the method RandomForeset over the data dfTitanic',
        'show precision and accuracy',
        'plot True Positive Rate vs Positive Predictive Value',
        'what is a good meat and potatoes recipe'
];

is openai-embeddings(@queries, format => "values", :$method).WHAT ∈ (Positional, Seq), True;

## 3
is openai-embeddings(@queries, format => "values", :$method).elems, @queries.elems;

done-testing;
