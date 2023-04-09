use v6.d;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::ChatCompletions;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


#============================================================
# Completions
#============================================================

#| OpenAI completion access.
our proto OpenAIChatCompletion($prompt is copy,
                               :$type is copy = Whatever,
                               :$role is copy = Whatever,
                               :$model is copy = Whatever,
                               :$temperature is copy = Whatever,
                               :$max-tokens is copy = Whatever,
                               :$n = 1,
                               :$auth-key is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny') is export {*}

#| OpenAI completion access.
multi sub OpenAIChatCompletion(@prompts, *%args) {
    return @prompts.map({ OpenAIChatCompletion($_, |%args) });
}

#| OpenAI completion access.
multi sub OpenAIChatCompletion($prompt is copy,
                               :$role is copy = Whatever,
                               :$model is copy = Whatever,
                               :$temperature is copy = Whatever,
                               :$max-tokens is copy = Whatever,
                               UInt :$n = 1,
                               :$auth-key is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny') {

    #------------------------------------------------------
    # Process $role
    #------------------------------------------------------
    if $role.isa(Whatever) { $role = "user"; }
    die "The argument \$role is expected to be Whatever or one of the strings: { '"' ~ $knownRoles.keys.sort.join('", "') ~ '"' }."
    unless $role ∈ $knownRoles;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'gpt-3.5-turbo'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ openai-known-models;

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

    my %body = :$model, messages => [%(:$role, content => $prompt),], :$temperature, max_tokens => $max-tokens, :$n;

    my $url = 'https://api.openai.com/v1/chat/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
