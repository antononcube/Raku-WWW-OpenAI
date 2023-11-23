#!/usr/bin/env raku
use v6.d;

use WWW::OpenAI;
use WWW::OpenAI::Models;

my $p = "Research the differences between Perl and Raku.";

#`[
say '/v1/completions';
my @models1 = |openai-end-point-to-models('/v1/completions');
for @models1 -> $model {
    say '-' x 60;
    say (:$model);
    say '-' x 60;
    say openai-completion("Expand upon: { $p }", :$model, temperature => 1.0, max-tokens => 400, format => 'hash')
}

say '=' x 120;
]

say '/v1/chat/completions';
my @models2 = |openai-end-point-to-models('/v1/chat/completions');
for @models2 -> $model {
    say '-' x 60;
    say (:$model);
    say '-' x 60;
    try {
        say openai-completion("Expand upon: { $p }", :$model, temperature => 1.0, max-tokens => 400, format => 'hash')
    }
    if $! {
        say "Failed."
    }
}

say '=' x 120;