use v6.d;

unit module WWW::OpenAI::Batches;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;


#============================================================
# Embeddings
#============================================================

#| OpenAI embeddings.
our proto OpenAIBatches(:$file-id = Whatever,
                        :$batch-id = Whatever,
                        Str :$operation = 'create',
                        :$endpoint is copy = Whatever,
                        :$completion-window is copy = Whatever,
                        UInt :$limit = 5,
                        :api-key(:$auth-key) is copy = Whatever,
                        UInt :$timeout= 10,
                        :$format is copy = Whatever,
                        Str :$method = 'tiny',
                        Str :$base-url = 'https://api.openai.com/v1'
                        ) is export {*}


#| OpenAI embeddings.
multi sub OpenAIBatches(:$file-id = Whatever,
                        :$batch-id = Whatever,
                        Str :$operation = 'create',
                        :$endpoint is copy = Whatever,
                        :$completion-window is copy = Whatever,
                        UInt :$limit = 5,
                        :api-key(:$auth-key) is copy = Whatever,
                        UInt :$timeout= 10,
                        :$format is copy = Whatever,
                        Str :$method = 'tiny',
                        Str :$base-url = 'https://api.openai.com/v1'
                        ) {

    #------------------------------------------------------
    # Process $file-id & $batch-id
    #------------------------------------------------------

    die 'At least one of the arguments $file-id and $batch-id is expected to be a string.'
    unless $file-id ~~ Str:D || $batch-id ~~ Str:D;

    die 'The argument $file-id is expected to be a string when $operation is "create".'
    unless $file-id ~~ Str:D && $operation eq 'create';

    die 'The argument $batch-id is expected to be a string when $operation is one "retrieve" or "cancel".'
    unless $batch-id ~~ Str:D && $operation ∈ <retrieve cancel>;

    #------------------------------------------------------
    # Process $endpoint
    #------------------------------------------------------
    if $endpoint.isa(Whatever) { $endpoint = '/v1/chat/completions'; }
    die "The argument \$endpoint is expected to be Whatever or a string."
    unless $endpoint ~~ Str:D;

    #------------------------------------------------------
    # Process $completion-window
    #------------------------------------------------------
    if $completion-window.isa(Whatever) { $completion-window = '24h'; }
    die "The argument \$completion-window is expected to be Whatever or a string."
    unless $completion-window ~~ Str:D;

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    return do given $operation {
        when 'create' {
            my $url = $base-url ~ '/batches';

            return openai-request(:$url,
                    body => to-json({ input_file_id => $file-id, :$endpoint, completion_window => $completion-window }),
                    :$auth-key, :$timeout, :$format, :$method);
        }

        when 'retrieve' {
            my $url = $base-url ~ "/batches/$batch-id";

            return openai-request(:$url,
                    body => (),
                    :$auth-key, :$timeout, :$format, :$method);
        }

        when 'cancel' {
            my $url = $base-url ~ "/batches/$batch-id/cancel";

            return openai-request(:$url,
                    body => (),
                    :$auth-key, :$timeout, :$format, :$method);
        }

        when 'list' {
            my $url = $base-url ~ "/batches?limit=$limit";

            return openai-request(:$url,
                    body => (),
                    :$auth-key, :$timeout, :$format, :$method);
        }
    }
}
