use v6.d;

use Cro::HTTP::Client;
use JSON::Fast;

unit module WWW::OpenAI;

# Open AI playground documentation
constant $maxTextsPerQuery = 50;

my $knownModels = Set.new(<gpt-3.5-turbo-0301 gpt-3.5-turbo>);
my $knownRoles = Set.new(<user assistant>);

#============================================================
# Get data by Cro
#============================================================

sub get-cro-post(Str $url, Str $auth-key, Str $body, UInt :$timeout = 10) {
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
# Get data from a URL
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
    my $res = get-cro-post($url, $auth-key, $textQuery, :$timeout);

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