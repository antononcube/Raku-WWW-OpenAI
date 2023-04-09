use v6.d;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::Embeddings;

#============================================================
# Embeddings
#============================================================

#| OpenAI embeddings.
our proto OpenAIEmbeddings($prompt,
                           :$model = Whatever,
                           :$auth-key is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'cro'
                           ) is export {*}


#| OpenAI embeddings.
multi sub OpenAIEmbeddings($prompt,
                           :$model is copy = Whatever,
                           :$auth-key is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'cro') {

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'text-embedding-ada-002'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ openai-known-models;

    #------------------------------------------------------
    # OpenAI URL
    #------------------------------------------------------

    my $url = 'https://api.openai.com/v1/embeddings';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    if ($prompt ~~ Positional || $prompt ~~ Seq) && $method ∈ <tiny> {

        return openai-request(:$url,
                body => to-json({ input => $prompt.Array, :$model }),
                :$auth-key, :$timeout, :$format, :$method);

    } else {

        return openai-request(:$url,
                body => to-json({ input => $prompt.Array, :$model }),
                :$auth-key, :$timeout, :$format, :$method);
    }
}
