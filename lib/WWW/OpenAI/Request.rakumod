use v6.d;

use JSON::Fast;
use HTTP::Tiny;

unit module WWW::OpenAI::Request;

#============================================================
# POST Tiny call
#============================================================

proto sub tiny-post(Str :$url!, |) is export {*}

multi sub tiny-post(Str :$url!,
                    Str :$body!,
                    Str :$auth-key!,
                    UInt :$timeout = 10) {
    my $resp = HTTP::Tiny.post: $url,
            headers => { authorization => "Bearer $auth-key",
                         Content-Type => "application/json" },
            content => $body;

    return $resp<content>.decode;
}

multi sub tiny-post(Str :$url!,
                    :$body! where *~~ Map,
                    Str :$auth-key!,
                    Bool :$json = False,
                    UInt :$timeout = 10) {
    if $json {
        return tiny-post(:$url, body => to-json($body), :$auth-key, :$timeout);
    }
    my $resp = HTTP::Tiny.post: $url,
            headers => { authorization => "Bearer $auth-key" },
            content => $body;
    return $resp<content>.decode;
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

multi sub curl-post(Str :$url!, Str :$body!, Str :$auth-key!, UInt :$timeout = 10) {

    my $textQuery = $curlQuery
            .subst('$URL', $url)
            .subst('$OPENAI_API_KEY', $auth-key)
            .subst('$BODY', $body);

    my $proc = shell $textQuery, :out, :err;

    say $proc.err.slurp(:close);

    return $proc.out.slurp(:close);
}

my $curlFormQuery = q:to/END/;
curl $URL \
  --header 'Authorization: Bearer $OPENAI_API_KEY' \
  --header 'Content-Type: multipart/form-data'
END

multi sub curl-post(Str :$url!,
                    :$body! where *~~ Map,
                    Str :$auth-key!,
                    UInt :$timeout = 10) {

    my $textQuery = $curlFormQuery
            .subst('$URL', $url)
            .subst('$OPENAI_API_KEY', $auth-key)
            .trim-trailing;

    for $body.kv -> $k, $v {
        my $sep = $k eq 'file' ?? '@' !! '';
        $textQuery ~= " \\\n  --form $k=$sep$v";
    }

    my $proc = shell $textQuery, :out, :err;

    say $proc.err.slurp(:close);

    return $proc.out.slurp(:close);
}


#============================================================
# Request
#============================================================

#| OpenAI request access.
our proto openai-request(Str :$url!,
                         :$body!,
                         :$auth-key is copy = Whatever,
                         UInt :$timeout= 10,
                         :$format is copy = Whatever,
                         Str :$method = 'tiny',
                         ) is export {*}

#| OpenAI request access.
multi sub openai-request(Str :$url!,
                         :$body!,
                         :$auth-key is copy = Whatever,
                         UInt :$timeout= 10,
                         :$format is copy = Whatever,
                         Str :$method = 'tiny'
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
    die "The argument \$method is expected to be a one of 'curl' or 'tiny'."
    unless $method ∈ <curl tiny>;

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
        when 'curl' {
            curl-post(:$url, :$body, :$auth-key, :$timeout);
        }
        when 'tiny' {
            tiny-post(:$url, :$body, :$auth-key, :$timeout);
        }
        default {
            die 'Unknown method.'
        }
    }

    #------------------------------------------------------
    # Result
    #------------------------------------------------------
    without $res { return Nil; }

    if $format.lc ∈ <asis as-is as_is> { return $res; }

    if $method ∈ <curl tiny> && $res ~~ Str {
        try {
            $res = from-json($res);
        }
        if $! {
            note 'Cannot convert from JSON, returning "asis".';
            return $res;
        }
    }

    return do given $format.lc {
        when $_ eq 'values' {
            if $res<choices>:exists {
                # Assuming text of chat completion
                my @res2 = $res<choices>.map({ $_<text> // $_<message><content> }).Array;
                @res2.elems == 1 ?? @res2[0] !! @res2;
            } elsif $res<data> {
                # Assuming image generation
                $res<data>.map({ $_<url> // $_<b64_json> // $_<embedding> }).Array;
            } elsif $res<results> {
                # Assuming moderation
                $res<results>.map({ $_<category_scores> // $_<categories> }).Array;
            } else {
                $res;
            }
        }
        when $_ ∈ <whatever hash raku> {
            if $res<choices>:exists {}
            $res<choices> // $res<data> // $res;
        }
        when $_ ∈ <json> { to-json($res); }
        default { $res; }
    }
}
