#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;

#say openai-completion("Why white chocolate exists?", n => 2, format => Whatever, method => 'cro');

#say openai-create-image(
#        "racoon with perls in the style of Hannah Wilke",
#        response-format => 'b64_json',
#        n => 1,
#        size => 'large',
#        format => Whatever,
#        method => 'cro');

#my $fileName = $*CWD ~ '/resources/New-Recording-32.mp3';
#my @modRes = |openai-audio(
#        $fileName,
#        format => "json",
#        method => 'tiny');
#
#for @modRes -> $m { .say for $m.pairs.sort(*.value).reverse; }

