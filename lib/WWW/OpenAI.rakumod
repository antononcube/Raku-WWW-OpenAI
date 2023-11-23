use v6.d;

use JSON::Fast;
use HTTP::Tiny;

unit module WWW::OpenAI;

use WWW::OpenAI::Audio;
use WWW::OpenAI::ChatCompletions;
use WWW::OpenAI::Embeddings;
use WWW::OpenAI::ImageEdits;
use WWW::OpenAI::ImageGenerations;
use WWW::OpenAI::ImageVariations;
use WWW::OpenAI::Models;
use WWW::OpenAI::Moderations;
use WWW::OpenAI::Request;
use WWW::OpenAI::TextCompletions;


#===========================================================
#| OpenAI audio transcriptions and translations access.
#| C<$file> -- file(s) to audio process;
#| C<:$type> -- type of processing, one of <transcriptions translations>
#| C<:$temperature> -- number between 0 and 2;
#| C<:$language> -- language to process to;
#| C<:$model> -- model;
#| C<:$prompt> -- prompt for the audio processing;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-audio(|) is export {*}

multi sub openai-audio(**@args, *%args) {
    return WWW::OpenAI::Audio::OpenAIAudio(|@args, |%args);
}

#===========================================================
#| OpenAI chat and text completions access.
#| C<:type> -- type of text generation, one of 'chat', 'text', or Whatever;
#| C<:model> -- LLM model to use.
#| C<*%args> -- additional arguments, see C<openai-chat-completion> and C<openai-text-completion>.
our proto openai-completion(|) is export {*}

multi sub openai-completion($prompt,
                            :$type is copy = Whatever,
                            :$model is copy = Whatever,
                            *%args) {

    #------------------------------------------------------
    # Process $type
    #------------------------------------------------------
    if $type.isa(Whatever) {
        $type = do given $model {
            when $_.isa(Whatever) && (so %args<images>) {
                $model = 'gpt-4-vision-preview';
                'chat'
            }
            when Whatever { 'text' }
            when openai-is-chat-completion-model($_) { 'chat' };
            when $_.starts-with('text-') { 'text' };
            default { 'text' }
        }
    }
    die "The argument \$type is expected to be one of 'chat', 'text', or Whatever."
    unless $type ∈ <chat text>;

    #------------------------------------------------------
    # Process $images
    #------------------------------------------------------
    if (%args<images> // False) && %args<images> !~~ Iterable {
        %args<images> = [%args<images>, ];
    }

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = $type eq 'text' ?? 'gpt-3.5-turbo-instruct' !! 'gpt-3.5-turbo'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-known-models.keys.sort.join('", "') ~ '"' }."
    unless $model ∈ openai-known-models;

    if $type eq 'chat' {
        return WWW::OpenAI::ChatCompletions::OpenAIChatCompletion($prompt, :$model, |%args);
    } else {
        return WWW::OpenAI::TextCompletions::OpenAITextCompletion($prompt, :$model, |%args);
    }
}

#===========================================================
#| OpenAI chat completions access.
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$n> -- number of answers;
#| C<:$stop> -- stop tokens;
#| C<:$stream> -- whether to stream the result or not;
#| C<:$presence-penalty> -- presence penalty;
#| C<:$frequency-penalty> -- frequency penalty;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-chat-completion(|) is export {*}

multi sub openai-chat-completion(**@args, *%args) {
    return WWW::OpenAI::ChatCompletions::OpenAIChatCompletion(|@args, |%args);
}

#===========================================================
#| OpenAI embeddings access.
#| C<$prompt> -- prompt to make embeddings for;
#| C<:$model> -- model;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-embeddings(|) is export {*}

multi sub openai-embeddings(**@args, *%args) {
    return WWW::OpenAI::Embeddings::OpenAIEmbeddings(|@args, |%args);
}

#===========================================================
#| OpenAI image generation access.
#| C<$prompt> -- prompt to generate the image with;
#| C<:$n> -- number of generated images;
#| C<:$size> -- size of the image, cat take one of <small medium large 256x256 512x512 1024x1024>;
#| C<:$response-format> -- image result format, one of <url b64_json>;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-create-image(|) is export {*}

multi sub openai-create-image(**@args, *%args) {
    return WWW::OpenAI::ImageGenerations::OpenAICreateImage(|@args, |%args);
}

#===========================================================
#| OpenAI image variation access.
#| C<$file> -- PNG image file to make edit(s) of;
#| C<$prompt> -- prompt to generate the edit with;
#| C<:$mask-file> -- PNG image file to mask the image given with C<$file>;
#| C<:$n> -- number of generated images;
#| C<:$size> -- size of the image, cat take one of <small medium large 256x256 512x512 1024x1024>;
#| C<:$response-format> -- image result format, one of <url b64_json>;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-edit-image(|) is export {*}

multi sub openai-edit-image(**@args, *%args) {
    return WWW::OpenAI::ImageEdits::OpenAIEditImage(|@args, |%args);
}

#===========================================================
#| OpenAI image variation access.
#| C<$file> -- file of a PNG to make variation(s) of;
#| C<:$n> -- number of generated images;
#| C<:$size> -- size of the image, cat take one of <small medium large 256x256 512x512 1024x1024>;
#| C<:$response-format> -- image result format, one of <url b64_json>;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-variate-image(|) is export {*}

multi sub openai-variate-image(**@args, *%args) {
    return WWW::OpenAI::ImageVariations::OpenAIVariateImage(|@args, |%args);
}

#===========================================================
#| OpenAI models access.
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout.
our proto openai-models(|) is export {*}

multi sub openai-models(*%args) {
    return WWW::OpenAI::Models::OpenAIModels(|%args);
}

#===========================================================
#| OpenAI moderations access.
#| C<$prompt> -- message(s) to be moderated;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-moderation(|) is export {*}

multi sub openai-moderation(**@args, *%args) {
    return WWW::OpenAI::Moderations::OpenAIModeration(|@args, |%args);
}

#===========================================================
#| OpenAI text completions access.
#| C<$prompt> -- message(s) to the LLM;
#| C<:$model> -- model;
#| C<:$suffix> -- suffix;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$n> -- number of answers;
#| C<:$stream> -- whether to stream the result or not;
#| C<:$echo> -- whether to echo the prompt or not;
#| C<:$presence-penalty> -- presence penalty;
#| C<:$frequency-penalty> -- frequency penalty;
#| C<:$best-of> -- number of best candidates to generate;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto openai-text-completion(|) is export {*}

multi sub openai-text-completion(**@args, *%args) {
    return WWW::OpenAI::TextCompletions::OpenAITextCompletion(|@args, |%args);
}

#============================================================
# Playground
#============================================================

#| OpenAI playground access.
#| C<:path> -- end point path;
#| C<:api-key(:$auth-key)> -- authorization key (API key);
#| C<:timeout> -- timeout
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>,
#| C<*%args> -- additional arguments, see C<openai-chat-completion> and C<openai-text-completion>.
our proto openai-playground($text is copy = '',
                            Str :$path = 'completions',
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            *%args
                            ) is export {*}

#| OpenAI playground access.
multi sub openai-playground(*%args) {
    return openai-playground('', |%args);
}

#| OpenAI playground access.
multi sub openai-playground(@texts, *%args) {
    return @texts.map({ openai-playground($_, |%args) });
}

#| OpenAI playground access.
multi sub openai-playground($text is copy,
                            Str :$path = 'completions',
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            *%args
                            ) {

    #------------------------------------------------------
    # Dispatch
    #------------------------------------------------------

    given $path.lc {
        when $_ eq 'models' {
            # my $url = 'https://api.openai.com/v1/models';
            return openai-models(:$auth-key, :$timeout);
        }
        when $_ ∈ <chat chat/completions> {
            # my $url = 'https://api.openai.com/v1/chat/completions';
            return openai-completion($text, type => 'chat',
                    |%args.grep({ $_.key ∈ <n model role max-tokens temperature> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <completion completions text/completions> {
            # my $url = 'https://api.openai.com/v1/completions';
            my $expectedKeys = <model prompt suffix max-tokens temperature top-p n stream echo presence-penalty frequency-penalty best-of stop>;
            return openai-text-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <create-image image-generation image-generations images-generations images/generations> {
            # my $url = 'https://api.openai.com/v1/images/generations';
            return openai-create-image($text, |%args.grep({ $_.key ∈ <n response-format size> }).Hash, :$auth-key,
                    :$timeout, :$format, :$method);
        }
        when $_ ∈ <edit-image image-edit image-edits images-edits images/edits> {
            # my $url = 'https://api.openai.com/v1/images/edits';
            return openai-edit-image($text, |%args.grep({ $_.key ∈ <n response-format size> }).Hash, :$auth-key,
                    :$timeout, :$format, :$method);
        }
        when $_ ∈ <variate-image image-variation image-variations images-variations images/variations> {
            # my $url = 'https://api.openai.com/v1/images/variations';
            return openai-variate-image($text, |%args.grep({ $_.key ∈ <n response-format size> }).Hash, :$auth-key,
                    :$timeout, :$format, :$method);
        }
        when $_ ∈ <moderations moderation censorship> {
            # my $url = 'https://api.openai.com/v1/moderations';
            return openai-moderation($text, :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <transcriptions transcription transcribe audio/transcriptions> {
            # my $url = 'https://api.openai.com/v1/audio';
            # Here $text is a file name
            return openai-audio($text,
                    |%args.grep({ $_.key ∈ <prompt model temperature language> }).Hash,
                    type => 'transcriptions', :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <translations translation translate audio/translations> {
            # my $url = 'https://api.openai.com/v1/audio';
            # Here $text is a file name
            return openai-audio($text,
                    |%args.grep({ $_.key ∈ <prompt model temperature language> }).Hash,
                    type => 'translations', :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <embedding embeddings> {
            # my $url = 'https://api.openai.com/v1/embeddings';
            return openai-embeddings($text,
                    |%args.grep({ $_.key ∈ <model> }).Hash,
                    :$auth-key, :$timeout, :$format, :$method);
        }
        default {
            die 'Do not know how to process the given path.';
        }
    }
}
