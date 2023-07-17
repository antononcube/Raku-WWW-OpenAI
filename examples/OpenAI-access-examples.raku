#!/usr/bin/env raku
use v6.d;

use WWW::OpenAI;
use Data::Reshapers;
use Data::Generators;

say openai-playground("how many rabits exist?", format => Whatever);

#say openai-create-image(
#        "racoon with perls in the style of Hannah Wilke",
#        response-format => 'b64_json',
#        n => 1,
#        size => 'large',
#        format => Whatever,
#        method => 'tiny');

#my $fileName = $*CWD ~ '/resources/New-Recording-32.mp3';
#my @modRes = |openai-audio(
#        $fileName,
#        format => "json",
#        method => 'tiny');
#
#for @modRes -> $m { .say for $m.pairs.sort(*.value).reverse; }
