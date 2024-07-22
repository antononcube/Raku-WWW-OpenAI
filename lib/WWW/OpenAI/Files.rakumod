use v6.d;

unit module WWW::OpenAI::Files;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;


#============================================================
# Embeddings
#============================================================

#| OpenAI embeddings.
our proto OpenAIFiles(:$file = Whatever,
                      :$file-id = Whatever,
                      Str :$operation = 'upload',
                      Str :$purpose = 'fine-tune',
                      :api-key(:$auth-key) is copy = Whatever,
                      UInt :$timeout= 10,
                      :$format is copy = Whatever,
                      Str :$method = 'tiny',
                      Str :$base-url = 'https://api.openai.com/v1'
                      ) is export {*}


#| OpenAI embeddings.
multi sub OpenAIFiles(:$file = Whatever,
                      :$file-id = Whatever,
                      Str :$operation = 'upload',
                      Str :$purpose = 'fine-tune',
                      :api-key(:$auth-key) is copy = Whatever,
                      UInt :$timeout= 10,
                      :$format is copy = Whatever,
                      Str :$method = 'tiny',
                      Str :$base-url = 'https://api.openai.com/v1'
                      ) {

    #------------------------------------------------------
    # Process $file-id & $batch-id
    #------------------------------------------------------

    die 'At least one of the arguments $file and $file-id is expected to be a string.'
    unless $file-id ~~ Str:D || $file-id ~~ Str:D;

    die 'The argument $fileis expected to be a string when $operation is "upload".'
    unless $file ~~ Str:D && $operation eq 'upload';

    die 'The argument $file-id is expected to be a string when $operation is one "retrieve", "content", or "delete".'
    unless $file-id ~~ Str:D && $operation ∈ <retrieve conent delete>;


    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    return do given $operation {
        when 'upload' {
            my $url = $base-url ~ '/files';

            return openai-request(:$url,
                    body => to-json({ :$file, :$purpose }),
                    :$auth-key, :$timeout, :$format, :$method);
        }

        when 'list' {
            my $url = $base-url ~ "/files";

            return openai-request(:$url,
                    body => to-json({ :$purpose }),
                    :$auth-key, :$timeout, :$format, :$method);
        }

        when 'retrieve' {
            my $url = $base-url ~ "/files/$file-id";

            return openai-request(:$url,
                    body => (),
                    :$auth-key, :$timeout, :$format, :$method);
        }

        when 'delete' {
            my $url = $base-url ~ "/files/$file-id";

            return tiny-delete(:$url, :$auth-key, :$timeout, :$format, :$method);
        }

        when 'content' {
            my $url = $base-url ~ "/files/$file-id/content";

            return openai-request(:$url,
                    body => (),
                    :$auth-key, :$timeout, :$format, :$method);
        }
    }
}
