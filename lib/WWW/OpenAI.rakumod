use v6.d;

use Cro::HTTP::Client;
use JSON::Fast;

unit module WWW::OpenAI;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);

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


#============================================================
# GET Cro call
#============================================================

sub get-cro-get(Str :$url, Str :$auth-key, UInt :$timeout = 10) {
    my $resp = await Cro::HTTP::Client.get: $url,
            headers => [
                Cro::HTTP::Header.new(
                        name => 'Content-Type',
                        value => 'application/json'
                        ),
                Cro::HTTP::Header.new(
                        name => 'Authorization',
                        value => "Bearer $auth-key"
                        )
            ];

    CATCH {
        when X::Cro::HTTP::Error {
            say "Problem fetching " ~ .request.target;
        }
    }
    return $resp.body;
}

#============================================================
# POST Cro call
#============================================================

sub get-cro-post(Str $body, Str :$url, Str :$auth-key, UInt :$timeout = 10) {
    my $resp = await Cro::HTTP::Client.post: $url,
            headers => [
                Cro::HTTP::Header.new(
                        name => 'Content-Type',
                        value => 'application/json'
                        ),
                Cro::HTTP::Header.new(
                        name => 'Authorization',
                        value => "Bearer $auth-key"
                        )
            ],
            :$body;

    return await $resp.body;
}

#============================================================
# Models
#============================================================

our sub openai-get-models(
        :$auth-key is copy = Whatever,
                          ) is export {
    my Str $url = 'https://api.openai.com/v1/models';

}

#============================================================
# Playground
#============================================================

#| OpenAI playground access.
our proto openai-playground($text is copy,
                            :$role is copy = Whatever,
                            :$model is copy = Whatever,
                            :$temperature is copy = Whatever,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever) is export {*}

#| OpenAI playground access.
multi sub openai-playground(@texts, *%args) {
    return @texts.map({ openai-playground($_, |%args) });
}

#| OpenAI playground access.
multi sub  openai-playground($text is copy,
                             :$role is copy = Whatever,
                             :$model is copy = Whatever,
                             :$temperature is copy = Whatever,
                             :$auth-key is copy = Whatever,
                             UInt :$timeout= 10,
                             :$format is copy = Whatever) {

    #------------------------------------------------------
    # Process $role
    #------------------------------------------------------
    if $role.isa(Whatever) { $role = "user"; }
    die "The argument \$role is expected to be Whatever or one of the strings: { $knownRoles.keys.sort.join(' ') }."
    unless $role ∈ $knownRoles;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = "gpt-3.5-turbo"; }
    die "The argument \$model is expected to be Whatever or one of the strings: { $knownModels.keys.sort.join(' ') }."
    unless $model ∈ $knownModels;

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0.7; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 1."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 1;

    #------------------------------------------------------
    # Process $format
    #------------------------------------------------------
    if $format.isa(Whatever) { $format = 'Whatever' }
    die "The argument format is expected to be a string or Whatever."
    unless $format ~~ Str;

    #------------------------------------------------------
    # Process $auth-key
    #------------------------------------------------------
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
    # Make DeepL URL
    #------------------------------------------------------
    my $textQuery = q:to/END/;
{
  "model": "$model",
  "messages": [{"role": "user", "content": "$content"}],
  "temperature": $temperature
}
END

    $textQuery =
            $textQuery
            .subst('$model', $model)
            .subst('$content', $text)
            .subst('$temperature', $temperature);

    my $url = 'https://api.openai.com/v1/chat/completions';

    #------------------------------------------------------
    # Invoke OpenAI service
    #------------------------------------------------------
    my $res = get-cro-post($textQuery, :$url, :$auth-key, :$timeout);

    #------------------------------------------------------
    # Result
    #------------------------------------------------------
    without $res { return Nil; }

    return do given $format.lc {
        when $_ ∈ <whatever hash raku> {
            $res<choices> // $res;
        }
        when $_ ∈ <json> { to-json($res); }
        when $_ ∈ <as-is> { $res; }
        default { $res; }
    }
}