use v6.d;

use WWW::OpenAI::Models;
use WWW::OpenAI::Request;
use JSON::Fast;
use MIME::Base64;
use Image::Markup::Utilities;

unit module WWW::OpenAI::ChatCompletions;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


#============================================================
# Completions
#============================================================

# In order to understand the design of [role => message,] argument see:
# https://platform.openai.com/docs/api-reference/chat/create


#| OpenAI completion access.
our proto OpenAIChatCompletion($prompt is copy,
                               :$role is copy = Whatever,
                               :$model is copy = Whatever,
                               :$temperature is copy = Whatever,
                               :$max-tokens is copy = Whatever,
                               Numeric :$top-p = 1,
                               UInt :$n = 1,
                               Bool :$stream = False,
                               :$stop = Whatever,
                               Numeric :$presence-penalty = 0,
                               Numeric :$frequency-penalty = 0,
                               :@images is copy = Empty,
                               :api-key(:$auth-key) is copy = Whatever,
                               UInt :$timeout= 10,
                               :$format is copy = Whatever,
                               Str :$method = 'tiny') is export {*}

#| OpenAI completion access.
multi sub OpenAIChatCompletion(Str $prompt, *%args) {
    return OpenAIChatCompletion([$prompt,], |%args);
}

#| OpenAI completion access.
multi sub OpenAIChatCompletion(@prompts is copy,
                               :$role is copy = Whatever,
                               :$model is copy = Whatever,
                               :$temperature is copy = Whatever,
                               :$max-tokens is copy = Whatever,
                               Numeric :$top-p = 1,
                               UInt :$n = 1,
                               Bool :$stream = False,
                               :$stop = Whatever,
                               Numeric :$presence-penalty = 0,
                               Numeric :$frequency-penalty = 0,
                               :@images is copy = Empty,
                               :api-key(:$auth-key) is copy = Whatever,
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
    if $model.isa(Whatever) { $model = @images ?? 'gpt-4-vision-preview' !! 'gpt-3.5-turbo'; }
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
    # Process @images
    #------------------------------------------------------
    die "The argument \@images is expected to be an empty Positional or a list of JPG image file names, image URLs, or base64 images."
    unless !@images ||
            [&&] @images.map({
                $_ ~~ / ^ 'http' .? '://' / || $_.IO.e || $_ ~~ / ^ 'data:image/' ['jpeg' | 'png'] ';base64' /
            });

    #------------------------------------------------------
    # Messages
    #------------------------------------------------------
    my @messages = @prompts.map({
        if $_ ~~ Pair {
            %(role => $_.key, content => $_.value)
        } else {
            %(:$role, content => $_)
        }
    });

    if @images {
        my $content = [
            { type => 'text', text => @messages.tail<content> },
            |@images.map({
                %(
                    type => 'image_url',
                    image_url => %( url => $_.IO.e ?? image-encode($_, type => 'jpeg') !! $_)
                )
            })
        ];
        @messages = @messages.head(*- 1).Array.push({ :$role, :$content });
    }

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my %body = :$model, :$temperature, :$stream, :$n,
               top_p => $top-p,
               :@messages,
               max_tokens => $max-tokens,
               presence_penalty => $presence-penalty,
               frequency_penalty => $frequency-penalty;

    my $url = 'https://api.openai.com/v1/chat/completions';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
