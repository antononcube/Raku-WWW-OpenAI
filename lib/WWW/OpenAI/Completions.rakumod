use v6.d;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;

unit module WWW::OpenAI::Completions;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


#============================================================
# Completions
#============================================================

my $textCompletitionStencil = q:to/END/;
{
  "model": "$model",
  "prompt": "$prompt",
  "temperature": $temperature,
  "max_tokens": $max-tokens,
  "n": $n
}
END

my $chatCompletitionStencil = q:to/END/;
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

#| OpenAI completion access.
our proto OpenAICompletion($prompt is copy,
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
multi sub OpenAICompletion(@prompts, *%args) {
    return @prompts.map({ OpenAICompletion($_, |%args) });
}

#| OpenAI completion access.
multi sub OpenAICompletion($prompt is copy,
                           :$type is copy = Whatever,
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
    # Process $type
    #------------------------------------------------------
    if $type.isa(Whatever) {
        $type = do given $model {
            when Whatever { 'text' }
            when $_.starts-with('text-') { 'text' };
            when $_ ∈ <gpt-3.5-turbo gpt-3.5-turbo-0301> { 'chat' };
            default { 'text' }
        }
    }
    die "The argument \$type is expected to be one of 'chat', 'text', or Whatever."
    unless $type ∈ <chat text>;

    #------------------------------------------------------
    # Process $role
    #------------------------------------------------------
    if $role.isa(Whatever) { $role = "user"; }
    die "The argument \$role is expected to be Whatever or one of the strings: { '"' ~ $knownRoles.keys.sort.join('", "') ~ '"' }."
    unless $role ∈ $knownRoles;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = $type eq 'text' ?? 'text-davinci-003' !! 'gpt-3.5-turbo'; }
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

    my $body = ($type eq 'chat' ?? $chatCompletitionStencil !! $textCompletitionStencil)
            .subst('$model', $model)
            .subst('$content', $prompt)
            .subst('$prompt', $prompt)
            .subst('$role', $role)
            .subst('$temperature', $temperature)
            .subst('$max-tokens', $max-tokens)
            .subst('$n', $n);

    my $url = $type eq 'chat' ?? 'https://api.openai.com/v1/chat/completions' !! 'https://api.openai.com/v1/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, :$body, :$auth-key, :$timeout, :$format, :$method);
}
