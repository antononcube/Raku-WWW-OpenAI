use v6.d;

use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::Moderations;

#============================================================
# Moderation
#============================================================

#| OpenAI image generation access.
our proto OpenAIModeration($prompt,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny'
                            ) is export {*}

#| OpenAI image generation access.
multi sub OpenAIModeration(@prompts, *%args) {
    return @prompts.map({ OpenAIModeration($_, |%args) });
}

#| OpenAI image generation access.
multi sub OpenAIModeration($prompt,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny') {

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my $body = to-json(%(input => $prompt));

    my $url = 'https://api.openai.com/v1/moderations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, :$body, :$auth-key, :$timeout, :$format, :$method);
}
