use v6.d;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::TextCompletions;


#============================================================
# Completions
#============================================================

my $textCompletitionStencil = q:to/END/;
{
  "model": "$model",
  "prompt": "$prompt",
  "suffix": "$suffix",
  "max_tokens": $max-tokens,
  "temperature": $temperature,
  "top_n": $top-p,
  "n": $n,
  "stream": $stream,
  "logprops": $logprops,
  "echo": $echo,
  "stop": "$stop",
  "presence_penalty": $presence-penalty,
  "frequency_penalty": $frequency-penalty,
  "best_of": $best-of,
  "user": "$user"
}
END



#| OpenAI completion access.
our proto OpenAITextCompletion($prompt is copy,
                               :$model is copy = Whatever,
                               :$suffix is copy = Whatever,
                               :$max-tokens is copy = Whatever,
                               :$temperature is copy = Whatever,
                               Numeric :$top-p = 1,
                               UInt :$n = 1,
                               Bool :$stream = False,
                               Bool :$echo = False,
                               :$stop = Whatever,
                               Numeric :$presence-penalty = 0,
                               Numeric :$frequency-penalty = 0,
                               :$best-of is copy = Whatever,
                               :$auth-key is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny') is export {*}

#| OpenAI completion access.
multi sub OpenAITextCompletion(@prompts, *%args) {
    return @prompts.map({ OpenAITextCompletion($_, |%args) });
}

#| OpenAI completion access.
multi sub OpenAITextCompletion($prompt is copy,
                               :$model is copy = Whatever,
                               :$suffix is copy = Whatever,
                               :$max-tokens is copy = Whatever,
                               :$temperature is copy = Whatever,
                               Numeric :$top-p = 1,
                               UInt :$n = 1,
                               Bool :$stream = False,
                               Bool :$echo = False,
                               :$stop = Whatever,
                               Numeric :$presence-penalty = 0,
                               Numeric :$frequency-penalty = 0,
                               :$best-of is copy = Whatever,
                               :$auth-key is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny') {

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = 'text-davinci-003'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ openai-known-models;

    #------------------------------------------------------
    # Process $suffix
    #------------------------------------------------------
    if !$suffix.isa(Whatever) {
        die "The argument \$suffix is expected to be a string or Whatever."
        unless $suffix ~~ Str;
    }

    #------------------------------------------------------
    # Process $max-tokens
    #------------------------------------------------------
    if $max-tokens.isa(Whatever) { $max-tokens = 16; }
    die "The argument \$max-tokens is expected to be Whatever or a positive integer."
    unless $max-tokens ~~ Int && 0 < $max-tokens;

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0.7; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 2."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 2;

    #------------------------------------------------------
    # Process $top-p
    #------------------------------------------------------
    if $top-p.isa(Whatever) { $top-p = 1.0; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 1."
    unless $top-p ~~ Numeric && 0 ≤ $top-p ≤ 1;

    #------------------------------------------------------
    # Process $n
    #------------------------------------------------------
    die "The argument \$n is expected to be a positive integer."
    unless 0 < $n;

    #------------------------------------------------------
    # Process $stream
    #------------------------------------------------------
    die "The argument \$stream is expected to be Boolean."
    unless $stream ~~ Bool;

    #------------------------------------------------------
    # Process $echo
    #------------------------------------------------------
    die "The argument \$echo is expected to be Boolean."
    unless $echo ~~ Bool;

    #------------------------------------------------------
    # Process $stop
    #------------------------------------------------------
    if !$stop.isa(Whatever) {
        die "The argument \$stop is expected to be a string, a list strings, or Whatever."
        unless $stop ~~ Str || $stop ~~ Positional && $stop.all ~~ Str;
    }

    #------------------------------------------------------
    # Process $presence-penalty
    #------------------------------------------------------
    die "The argument \$presence-penalty is expected to be Boolean."
    unless $presence-penalty ~~ Numeric && -2 ≤ $presence-penalty ≤ 2;

    #------------------------------------------------------
    # Process $frequency-penalty
    #------------------------------------------------------
    die "The argument \$frequency-penalty is expected to be Boolean."
    unless $frequency-penalty ~~ Numeric && -2 ≤ $frequency-penalty ≤ 2;

    #------------------------------------------------------
    # Process $best-of
    #------------------------------------------------------
    if !$best-of.isa(Whatever) {
        die "The argument \$best-of is expected to be a positive integer or Whatever."
        unless $best-of ~~ UInt && 1 ≤ $best-of;
    }

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my %body = :$model, :$prompt, :$suffix, max_tokens => $max-tokens, :$temperature,
               top_p => $top-p, :$n,
               :$stream, :$echo,
               presence_penalty => $presence-penalty,
               frequency_penalty => $frequency-penalty;

    if !$stop.isa(Whatever) { %body<stop> = $stop; }
    if !$suffix.isa(Whatever) { %body<suffix> = $suffix; }
    if !$best-of.isa(Whatever) { %body<best_of> = $best-of; }

    my $url = 'https://api.openai.com/v1/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
