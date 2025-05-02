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
                           "curie-similarity", "cushman:2020-05-03",
                           "dall-e-2", "dall-e-3", "gpt-image-1",
                           "davinci",
                           "davinci:2020-05-03", "davinci-if:3.0.0", "davinci-instruct-beta",
                           "davinci-instruct-beta:2.0.0", "davinci-search-document",
                           "davinci-search-query", "davinci-similarity",
                           "o4-mini", "o4-mini-2025-04-16",
                           "o3", "o3-2025-04-16",
                           "o3-mini", "o3-mini-2025-01-31",
                           "o1-preview", "o1-preview-2024-09-12", "o1-mini", "o1-mini-2024-09-12",
                           "chatgpt-4o-latest",
                           "gpt-4-vision-preview", "gpt-4-1106-preview",
                           "gpt-4.1", "gpt-4.1-2025-04-14",
                           "gpt-4.1-mini", "gpt-4.1-mini-2025-04-14",
                           "gpt-4.1-nano", "gpt-4.1-nano-2025-04-14",
                           "gpt-4o", "gpt-4o-2024-05-13", "gpt-4o-2024-08-06", "chatgpt-4o-latest",
                           "gpt-4o-mini", "gpt-4o-mini-2024-07-18",
                           "gpt-4-turbo", "gpt-4-turbo-2024-04-09",
                           "gpt-4-turbo-preview", "gpt-4-1106-vision-preview", "gpt-4-0125-preview",
                           "gpt-4", "gpt-4-32k",
                           "gpt-4-0613", "gpt-4-32k-0613",
                           "gpt-4-0314", "gpt-4-32k-0314",
                           "gpt-3.5-turbo", "gpt-3.5-turbo-1106", "gpt-3.5-turbo-0125",
                           "gpt-3.5-turbo-16k-0613", "gpt-3.5-turbo-16k",
                           "gpt-3.5-turbo-0613", "gpt-3.5-turbo-0301", "gpt-3.5-turbo-instruct",
                           "if-curie-v2", "if-davinci:3.0.0",
                           "if-davinci-v2", "text-ada-001", "text-ada:001", "text-babbage-001",
                           "text-babbage:001", "text-curie-001", "text-curie:001",
                           "text-davinci-001", "text-davinci:001", "text-davinci-002",
                           "text-davinci-003", "text-davinci-edit-001",
                           "text-davinci-insert-001", "text-davinci-insert-002",
                           "text-embedding-3-large", "text-embedding-3-small",
                           "text-embedding-002", "text-embedding-ada-002",
                           "text-search-ada-doc-001",
                           "text-search-ada-query-001", "text-search-babbage-doc-001",
                           "text-search-babbage-query-001", "text-search-curie-doc-001",
                           "text-search-curie-query-001", "text-search-davinci-doc-001",
                           "text-search-davinci-query-001", "text-similarity-ada-001",
                           "text-similarity-babbage-001", "text-similarity-curie-001",
                           "text-similarity-davinci-001",
                           "whisper-1",
                           "tts-1", "tts-1-hd"]);


our sub openai-known-models() is export {
    return $knownModels;
}

#============================================================
# Compatibility of models and end-points
#============================================================

# Taken from:
# https://platform.openai.com/docs/models/model-endpoint-compatibility

my %endPointToModels =
        '/v1/assistants' => [|openai-known-models.grep(* ~~ / ^ ['gpt-4' | 'o' \d '-'] / ).Hash.keys, |<gpt-3.5-turbo gpt-3.5-turbo-1106>],
        '/v1/chat/completions' => [|openai-known-models.grep(* ~~ / ^ ['gpt-4' | 'o' \d '-'] / ).Hash.keys, |<chatgpt-4o-latest gpt-3.5-turbo gpt-3.5-turbo-0301 gpt-3.5-turbo-1106>],
        '/v1/completions' => <gpt-3.5-turbo gpt-3.5-turbo-instruct text-davinci-003 text-davinci-002 text-curie-001 text-babbage-001 text-ada-001>,
        '/v1/edits' => <text-davinci-edit-001 code-davinci-edit-001>,
        '/v1/audio/speech' => <tts-1 tts-1-hd>,
        '/v1/audio/transcriptions' => <whisper-1>,
        '/v1/audio/translations' => <whisper-1>,
        '/v1/images/generations' => <dall-e-2 dall-e-3>,
        '/v1/fine-tunes' => <davinci curie babbage ada>,
        '/v1/fine-tunes/jobs' => <gpt-3.5-turbo babbage-002 davinci-002>,
        '/v1/embeddings' =>  [|openai-known-models.grep(* ~~ / ^ 'text-embedding' / ).Hash.keys, 'text-search-ada-doc-001'],
        '/v1/moderations' => <text-moderation-stable text-moderation-latest>;

#| End-point to models retrieval.
proto sub openai-end-point-to-models(|) is export {*}

multi sub openai-end-point-to-models() {
    return %endPointToModels;
}

multi sub openai-end-point-to-models(Str $endPoint) {
    return %endPointToModels{$endPoint};
}

#| Checks if a given string an identifier of a chat completion model.
proto sub openai-is-chat-completion-model($model) is export {*}

multi sub openai-is-chat-completion-model(Str $model) {
    return $model ∈ openai-end-point-to-models{'/v1/chat/completions'};
}

#| Checks if a given string an identifier of a text completion model.
proto sub openai-is-text-completion-model($model) is export {*}

multi sub openai-is-text-completion-model(Str $model) {
    return $model ∈ openai-end-point-to-models{'/v1/completions'};
}

#------------------------------------------------------------
# Invert to get model-to-end-point correspondence.
# At this point (2023-04-14) only the model "whisper-1" has more than one end-point.
my %modelToEndPoints = %endPointToModels.map({ $_.value.Array X=> $_.key }).flat.classify({ $_.key }).map({ $_.key => $_.value>>.value.Array });

#| Model to end-points retrieval.
proto sub openai-model-to-end-points(|) is export {*}

multi sub openai-model-to-end-points() {
    return %modelToEndPoints;
}

multi sub openai-model-to-end-points(Str $model) {
    return %modelToEndPoints{$model};
}

#============================================================
# Models
#============================================================

#| OpenAI models.
our sub OpenAIModels(:api-key(:$auth-key) is copy = Whatever,
                     UInt :$timeout = 10,
                     Str :$method = 'tiny',
                     Str :$base-url = 'https://api.openai.com/v1') is export {
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
    my Str $url = $base-url ~ '/models';

    my $resp = HTTP::Tiny.get: $url,
            headers => { authorization => "Bearer $auth-key" };

    my $res = from-json($resp<content>.decode);

    return $res<data>.map(*<id>).sort;
}
