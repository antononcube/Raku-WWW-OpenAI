#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;

#use Cro::HTTP::Client;
#my $resp = await Cro::HTTP::Client.get('https://www.raku.org/');

say openai-completion("Why white chocolate exists?", n => 2, format => Whatever, method => 'cro');

#say openai-create-image(
#        "racoon with perls in the style of Hannah Wilke",
#        response-format => 'b64_json',
#        n => 1,
#        :$auth-key,
#        format => Whatever,
#        method => 'cro');