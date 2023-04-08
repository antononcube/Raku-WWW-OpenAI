use v6.d;

use WWW::OpenAI::Request;

unit module WWW::OpenAI::Moderations;

#============================================================
# Moderation
#============================================================

my $moderationStencil = q:to/END/;
{
  "input": "$prompt"
}
END

#| OpenAI image generation access.
our proto OpenAIModeration($prompt,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'cro'
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
                            Str :$method = 'cro') {

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my $body = $moderationStencil
            .subst('$prompt', $prompt);

    my $url = 'https://api.openai.com/v1/moderations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, :$body, :$auth-key, :$timeout, :$format, :$method);
}
