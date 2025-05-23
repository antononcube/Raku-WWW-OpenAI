use v6.d;
unit module WWW::OpenAI::Embeddings;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;


#============================================================
# Embeddings
#============================================================

#| OpenAI embeddings.
our proto OpenAIEmbeddings($prompt,
                           :$model = Whatever,
                           :$encoding-format = Whatever,
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = 'https://api.openai.com/v1'
                           ) is export {*}


#| OpenAI embeddings.
multi sub OpenAIEmbeddings($prompt,
                           :$model is copy = Whatever,
                           :$encoding-format is copy = Whatever,
                           :api-key(:$auth-key) is copy = Whatever,
                           UInt :$timeout= 10,
                           :$format is copy = Whatever,
                           Str :$method = 'tiny',
                           Str :$base-url = 'https://api.openai.com/v1') {

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'text-embedding-ada-002'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ openai-known-models;

    #------------------------------------------------------
    # Process $encoding-format
    #------------------------------------------------------
    if $encoding-format.isa(Whatever) { $encoding-format = 'float'; }
    die "The argument \$encoding-format is expected to be Whatever or one of the strings 'float' or 'base64'."
    unless $encoding-format ~~ Str:D && $encoding-format.lc ∈ <float base64>;

    #------------------------------------------------------
    # OpenAI URL
    #------------------------------------------------------

    my $url = $base-url ~ '/embeddings';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    if ($prompt ~~ Positional || $prompt ~~ Seq) && $method ∈ <tiny> {

        return openai-request(:$url,
                body => to-json({ input => $prompt.Array, :$model, encoding_format => $encoding-format}),
                :$auth-key, :$timeout, :$format, :$method);

    } else {

        return openai-request(:$url,
                body => to-json({ input => $prompt.Array, :$model, encoding_format => $encoding-format}),
                :$auth-key, :$timeout, :$format, :$method);
    }
}
