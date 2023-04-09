use v6.d;

use WWW::OpenAI::Request;
use HTTP::Tiny;
use JSON::Fast;

unit module WWW::OpenAI::Models;


#============================================================
# Known models
#============================================================
# https://platform.openai.com/docs/api-reference/models/list

my $knownModels = Set.new(["ada", "ada:2020-05-03", "ada-code-search-code",
                           "ada-code-search-text", "ada-search-document", "ada-search-query",
                           "ada-similarity", "babbage", "babbage:2020-05-03",
                           "babbage-code-search-code", "babbage-code-search-text",
                           "babbage-search-document", "babbage-search-query",
                           "babbage-similarity", "code-cushman-001", "code-davinci-002",
                           "code-davinci-edit-001", "code-search-ada-code-001",
                           "code-search-ada-text-001", "code-search-babbage-code-001",
                           "code-search-babbage-text-001", "curie", "curie:2020-05-03",
                           "curie-instruct-beta", "curie-search-document", "curie-search-query",
                           "curie-similarity", "cushman:2020-05-03", "davinci",
                           "davinci:2020-05-03", "davinci-if:3.0.0", "davinci-instruct-beta",
                           "davinci-instruct-beta:2.0.0", "davinci-search-document",
                           "davinci-search-query", "davinci-similarity", "gpt-3.5-turbo",
                           "gpt-3.5-turbo-0301", "if-curie-v2", "if-davinci:3.0.0",
                           "if-davinci-v2", "text-ada-001", "text-ada:001", "text-babbage-001",
                           "text-babbage:001", "text-curie-001", "text-curie:001",
                           "text-davinci-001", "text-davinci:001", "text-davinci-002",
                           "text-davinci-003", "text-davinci-edit-001",
                           "text-davinci-insert-001", "text-davinci-insert-002",
                           "text-embedding-ada-002", "text-search-ada-doc-001",
                           "text-search-ada-query-001", "text-search-babbage-doc-001",
                           "text-search-babbage-query-001", "text-search-curie-doc-001",
                           "text-search-curie-query-001", "text-search-davinci-doc-001",
                           "text-search-davinci-query-001", "text-similarity-ada-001",
                           "text-similarity-babbage-001", "text-similarity-curie-001",
                           "text-similarity-davinci-001", "whisper-1"]);


our sub openai-known-models() is export {
    return $knownModels;
}

#============================================================
# Models
#============================================================

#| OpenAI models.
our sub OpenAIModels(:$auth-key is copy = Whatever, UInt :$timeout = 10) is export {
    #------------------------------------------------------
    # Process $auth-key
    #------------------------------------------------------
    # This code is repeated below.
    if $auth-key.isa(Whatever) {
        if %*ENV<OPENAI_API_KEY>:exists {
            $auth-key = %*ENV<OPENAI_API_KEY>;
        } else {
            note 'Cannot find OpenAI authorization key. ' ~
                    'Please provide a valid key to the argument auth-key, or set the ENV variable OPENAI_API_KEY.';
            $auth-key = ''
        }
    }
    die "The argument auth-key is expected to be a string or Whatever."
    unless $auth-key ~~ Str;

    #------------------------------------------------------
    # Retrieve
    #------------------------------------------------------
    my Str $url = 'https://api.openai.com/v1/models';

    my $resp = HTTP::Tiny.get: $url,
            headers => { authorization => "Bearer $auth-key" };

    my $res = from-json($resp<content>.decode);

    return $res<data>.map(*<id>).sort;
}