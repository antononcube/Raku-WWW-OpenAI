unit module WWW::OpenAI::Audio;

use JSON::Fast;
use WWW::OpenAI::Request;


#============================================================
# Audio
#============================================================

#| OpenAI image generation access.
our proto OpenAIAudio($file,
                      :$type = 'transcriptions',
                      Str :$prompt = '',
                      :$temperature is copy = Whatever,
                      :$language is copy = Whatever,
                      :$voice is copy = Whatever,
                      Numeric :$speed = 1.0,
                      :$model is copy = Whatever,
                      :api-key(:$auth-key) is copy = Whatever,
                      UInt :$timeout= 10,
                      :response-format(:$format) is copy = Whatever,
                      Str :$method = 'tiny',
                      Str :$base-url = 'https://api.openai.com/v1'
                      ) is export {*}

#| OpenAI image generation access.
multi sub OpenAIAudio(@fileNames, *%args) {
    return @fileNames.map({ OpenAIAudio($_, |%args) });
}

#| OpenAI image generation access.
multi sub OpenAIAudio($file,
                      :$type is copy = 'transcriptions',
                      Str :$prompt = '',
                      :$temperature is copy = Whatever,
                      :$language is copy = Whatever,
                      :$voice is copy = Whatever,
                      Numeric :$speed = 1.0,
                      :$model is copy = Whatever,
                      :api-key(:$auth-key) is copy = Whatever,
                      UInt :$timeout= 10,
                      :response-format(:$format) is copy = Whatever,
                      Str :$method = 'tiny',
                      Str :$base-url = 'https://api.openai.com/v1') {

    #------------------------------------------------------
    # Process type
    #------------------------------------------------------
    if $type.isa(Whatever) { $type = 'transcriptions'; }
    my @expectedTypes = <speech transcriptions translations>;
    die "The value of the argument \$type is expected to be one of { @expectedTypes.join(', ') }."
    unless $type ~~ Str:D && $type.lc ∈ @expectedTypes;

    $type = $type.lc;

    #------------------------------------------------------
    # Process file name
    #------------------------------------------------------
    # Verify file exists
    die "The file '$file' does not exists."
    unless $type eq 'speech' || $type ∈ <transcriptions translations> && $file.IO.e;

    #------------------------------------------------------
    # Process voice
    #------------------------------------------------------
    if $voice.isa(Whatever) { $voice = 'echo'; }
    # Maybe, the actual verification _and_ rejection should be left to OpenAI
    my @expectedVoices = <alloy echo fable onyx nova shimmer>;
    die "The value of the argument \$voice is expected to be one of { @expectedVoices.join(', ') }."
    unless $voice ~~ Str:D && $voice.lc ∈ @expectedVoices;

    $voice = $voice.lc;

    #------------------------------------------------------
    # Process format
    #------------------------------------------------------
    if $type ∈ <transcriptions translations> {

        if $format.isa(Whatever) { $format = 'json'}
        my @expectedFormats = <json text srt verbose_json vtt>;
        die "For transcriptions and translations the value of the argument \$format is expected to be one of { @expectedFormats.join(', ') }."
        unless $format ~~ Str && $format.lc ∈ @expectedFormats;

    } else {

        if $format.isa(Whatever) { $format = 'mp3'}
        my @expectedFormats = <mp3 opus aac flac>;
        die "For speech audio generation the value of the argument \$format is expected to be one of { @expectedFormats.join(', ') }."
        unless $format ~~ Str && $format.lc ∈ @expectedFormats;
    }

    #------------------------------------------------------
    # Process $temperature
    #------------------------------------------------------
    if $temperature.isa(Whatever) { $temperature = 0; }
    die "The argument \$temperature is expected to be Whatever or number between 0 and 1."
    unless $temperature ~~ Numeric && 0 ≤ $temperature ≤ 1;

    #------------------------------------------------------
    # Process $language
    #------------------------------------------------------
    if $language.isa(Whatever) { $language = ''; }

    #------------------------------------------------------
    # Process $speed
    #------------------------------------------------------
    die 'The argument $speed is expected to be a number between 0.25 and 4.'
    unless 0.25 ≤ $speed ≤ 4.0;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $type ∈ <transcriptions translations> {

        # The API documentation states that only 'whisper-1' is available. (2023-03-29)
        if $model.isa(Whatever) { $model = 'whisper-1'; }
        my @expectedModels = <whisper-1>;
        die "For transcriptions and translations the value of the argument \$model is expected to be one of { @expectedModels.join(', ') }."
        unless $model ~~ Str && $model.lc ∈ @expectedModels;

    } else {

        if $model.isa(Whatever) { $model = 'tts-1' }
        my @expectedModels = <tts-1 tts-1-hd>;
        die "For speech audio generation the value of the argument \$model is expected to be one of { @expectedModels.join(', ') }."
        unless $model ~~ Str && $model.lc ∈ @expectedModels;
    }

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my $url = $base-url ~ '/audio/' ~ $type;

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    if $type ∈ <transcriptions translations> {

        if $method eq 'curl' {
            # Some sort of no-good shortcut -- see curl-post
            my %body = %(:$file, :$model, :$prompt, :$language, :$temperature, response_format => $format);

            return openai-request(:$url, :%body, :$auth-key, :$timeout, :$format, :$method);

        } elsif $method eq 'tiny' {

            my %body = :$model, :$temperature, response_format => $format;

            if $prompt { %body<prompt> = $prompt; }

            if $language { %body<language> = $language; }

            %body<file> = $file.IO;

            return openai-request(:$url, :%body, :$auth-key, :$timeout, :$format, :$method);
        }

    } else {

        if $method eq 'curl' {

            my %body = %(input => $prompt, :$model, response_format => $format, :$voice, :$speed);

            return openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$method, output-file => $file);

        } elsif $method eq 'tiny' {

            my %body = %(input => $prompt, :$model, :$voice, :$speed, response_format => $format);

            my $res = openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$method, format => 'asis', output-file => $file);

            return $res;
        }
    }
}
