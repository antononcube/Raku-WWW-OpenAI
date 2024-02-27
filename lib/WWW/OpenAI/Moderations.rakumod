use v6.d;

use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::Moderations;

#============================================================
# Moderation
#============================================================

#| OpenAI image generation access.
our proto OpenAIModeration($prompt,
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = 'https://api.openai.com/v1'
                            ) is export {*}

#| OpenAI image generation access.
multi sub OpenAIModeration(@prompts, *%args) {
    return @prompts.map({ OpenAIModeration($_, |%args) });
}

#| OpenAI image generation access.
multi sub OpenAIModeration($prompt,
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = 'https://api.openai.com/v1') {

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my $body = to-json(%(input => $prompt));

    my $url = $base-url ~ '/moderations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, :$body, :$auth-key, :$timeout, :$format, :$method);
}
