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

sub get-cro-post(Str :$url!, Str :$body!, Str :$auth-key!, UInt :$timeout = 10) {
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
# POST Curl call
#============================================================
my $curlQuery = q:to/END/;
curl $URL \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer $OPENAI_API_KEY' \
  -d '$BODY'
END

sub get-curl-post(Str :$url!, Str :$body!, Str :$auth-key!, UInt :$timeout = 10) {

    my $textQuery = $curlQuery
            .subst('$URL', $url)
            .subst('$OPENAI_API_KEY', $auth-key)
            .subst('$BODY', $body);

    my $proc = shell $textQuery, :out, :err;

    say $proc.err.slurp(:close);

    return $proc.out.slurp(:close);
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
# Request
#============================================================

#| OpenAI request access.
our proto openai-request(Str :$url!,
                         Str :$body!,
                         :$auth-key is copy = Whatever,
                         UInt :$timeout= 10,
                         :$format is copy = Whatever,
                         Str :$method = 'cro'
                         ) is export {*}

#| OpenAI request access.
multi sub  openai-request(Str :$url!,
                          Str :$body!,
                          :$auth-key is copy = Whatever,
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          Str :$method = 'cro'
                          ) {

    #------------------------------------------------------
    # Process $format
    #------------------------------------------------------
    if $format.isa(Whatever) { $format = 'Whatever' }
    die "The argument format is expected to be a string or Whatever."
    unless $format ~~ Str;

    #------------------------------------------------------
    # Process $method
    #------------------------------------------------------
    die "The argument \$method is expected to be a one of 'cro' or 'curl'."
    unless $method ∈ <cro curl>;

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
    # Invoke OpenAI service
    #------------------------------------------------------
    my $res = do given $method.lc {
        when 'cro' {
            get-cro-post(:$url, :$body, :$auth-key, :$timeout);
        }
        when 'curl' {
            get-curl-post(:$url, :$body, :$auth-key, :$timeout);
        }
        default {
            die 'Unknown method.'
        }
    }

    #------------------------------------------------------
    # Result
    #------------------------------------------------------
    without $res { return Nil; }

    if $method eq 'cro' {
        return do given $format.lc {
            when $_ ∈ <whatever hash raku> {
                $res<choices> // $res<data> // $res;
            }
            when $_ ∈ <json> { to-json($res); }
            when $_ ∈ <as-is> { $res; }
            default { $res; }
        }
    } else {
        return do given $format.lc {
            when $_ ∈ <whatever hash raku> {
                my $t = from-json($res);
                $t<choices> // $t<data> // $t;
            }
            when $_ ∈ <json> { to-json(from-json($res)); }
            when $_ ∈ <as-is> { $res; }
            default { from-json($res); }
        }
    }
}


#============================================================
# Completions
#============================================================

my $completitionStencil = q:to/END/;
{
  "model": "$model",
  "messages": [{"role": "user", "content": "$content"}],
  "temperature": $temperature,
  "max_tokens": $max-tokens,
  "n": $n
}
END

#my $completitionStencil = q:to/END/;
#{
#  "model": "$model",
#  "prompt": "$prompt",
#  "temperature": $temperature,
#  "max_tokens": $max-tokens,
#  "n": $n
#}
#END

#| OpenAI playground access.
our proto openai-completion($prompt is copy,
                            :$role is copy = Whatever,
                            :$model is copy = Whatever,
                            :$temperature is copy = Whatever,
                            :$max-tokens is copy = Whatever,
                            :$n = 1,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'cro') is export {*}

#| OpenAI playground access.
multi sub openai-completion(@prompts, *%args) {
    return @prompts.map({ openai-completion($_, |%args) });
}

#| OpenAI playground access.
multi sub  openai-completion($prompt is copy,
                             :$role is copy = Whatever,
                             :$model is copy = Whatever,
                             :$temperature is copy = Whatever,
                             :$max-tokens is copy = Whatever,
                             UInt :$n = 1,
                             :$auth-key is copy = Whatever,
                             UInt :$timeout= 10,
                             :$format is copy = Whatever,
                             Str :$method = 'cro') {

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
    die "The argument \$temperature is expected to be Whatever or number between 0 and 2."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 2;

    #------------------------------------------------------
    # Process $max-tokens
    #------------------------------------------------------
    if $max-tokens.isa(Whatever) { $max-tokens = 16; }
    die "The argument \$max-tokens is expected to be Whatever or a positive integer."
    unless $max-tokens ~~ Int && 0 < $max-tokens;

    #------------------------------------------------------
    # Process $n
    #------------------------------------------------------
    die "The argument \$n is expected to be a positive integer."
    unless 0 < $n;

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my $body = $completitionStencil
            .subst('$model', $model)
            .subst('$content', $prompt)
            .subst('$role', $role)
            .subst('$temperature', $temperature)
            .subst('$max-tokens', $max-tokens)
            .subst('$n', $n);

    my $url = 'https://api.openai.com/v1/chat/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, :$body, :$auth-key, :$timeout, :$format, :$method);
}


#============================================================
# Images generation
#============================================================

my $imageGenerationStencil = q:to/END/;
{
  "prompt": "$prompt",
  "n": $n,
  "size": "$size",
  "response_format" : "$response-format"
}
END

#| OpenAI playground access.
our proto openai-create-image($prompt,
                              UInt :$n = 1,
                              :$size is copy = Whatever,
                              :$response-format is copy = Whatever,
                              :$auth-key is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'cro'
                              ) is export {*}

#| OpenAI playground access.
multi sub openai-create-image(@prompts, *%args) {
    return @prompts.map({ openai-completion($_, |%args) });
}

#| OpenAI playground access.
multi sub openai-create-image($prompt,
                              UInt :$n = 1,
                              :$size is copy = Whatever,
                              :$response-format is copy = Whatever,
                              :$auth-key is copy = Whatever,
                              UInt :$timeout= 10,
                              :$format is copy = Whatever,
                              Str :$method = 'cro') {

    #------------------------------------------------------
    # Process $n
    #------------------------------------------------------
    die "The argument \$n is expected to be a positive integer."
    unless 0 < $n;

    #------------------------------------------------------
    # Process $size
    #------------------------------------------------------
    if $size.isa(Whatever) { $size = '256x256'; }
    my %sizeMap = small => '256x256', medium => '512x512', 'large' => '1024x1024';
    %sizeMap = %sizeMap , %sizeMap.values.map({ $_ => $_ }).Hash;

    die "The argument \$size is expected to be Whatever or one of '{%sizeMap.keys.join(', ')}', '{%sizeMap.values.join(', ')}'."
    unless %sizeMap{$size}:exists;

    #------------------------------------------------------
    # Process $response_format
    #------------------------------------------------------
    if $response-format.isa(Whatever) { $response-format = 'url'; }
    die "The argument \$response_format is expected to be Whatever or one of 'url' or 'b64_json'."
    unless $response-format ∈ <url b64_json>;

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my $body = $imageGenerationStencil
            .subst('$prompt', $prompt)
            .subst('$size', $size)
            .subst('$response-format', $response-format)
            .subst('$n', $n);

    my $url = 'https://api.openai.com/v1/images/generations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, :$body, :$auth-key, :$timeout, :$format, :$method);
}


#============================================================
# Playground
#============================================================

#| OpenAI playground access.
our proto openai-playground($text is copy,
                            Str :$path = 'completions',
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'cro',
                            *%args
                            ) is export {*}

#| OpenAI playground access.
multi sub openai-playground(@texts, *%args) {
    return @texts.map({ openai-playground($_, |%args) });
}

#| OpenAI playground access.
multi sub  openai-playground($text is copy,
                             Str :$path = 'completions',
                             :$auth-key is copy = Whatever,
                             UInt :$timeout= 10,
                             :$format is copy = Whatever,
                             Str :$method = 'cro',
                             *%args
                             ) {

    #------------------------------------------------------
    # Dispatch
    #------------------------------------------------------

    given $path.lc {
        when $_ ∈ <completions chat/completions> {
            my $url = 'https://api.openai.com/v1/chat/completions';
            return openai-completion($text, |%args.grep({ $_.key ∈ <n model role max-tokens temperature> }).Hash, :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <create-image images/generations> {
            my $url = 'https://api.openai.com/v1/images/generations';
            return openai-create-image($text, |%args.grep({ $_.key ∈ <n response-format size> }).Hash, :$auth-key, :$timeout, :$format, :$method);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}