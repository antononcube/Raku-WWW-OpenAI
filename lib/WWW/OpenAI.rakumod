use v6.d;

use Cro::HTTP::Client;
use JSON::Fast;
use HTTP::Tiny;

unit module WWW::OpenAI;

use WWW::OpenAI::Audio;
use WWW::OpenAI::ChatCompletions;
use WWW::OpenAI::Embeddings;
use WWW::OpenAI::ImageGenerations;
use WWW::OpenAI::Models;
use WWW::OpenAI::Moderations;
use WWW::OpenAI::Request;
use WWW::OpenAI::TextCompletions;


#===========================================================
#| OpenAI audio transcriptions and translations access.
our proto openai-audio(|) is export {*}

multi sub openai-audio(**@args, *%args) {
    return WWW::OpenAI::Aidio::OpenAIAudio(|@args, |%args);
}

#===========================================================
#| OpenAI chat and text completions access.
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
            when Whatever { 'text' }
            when $_.starts-with('text-') { 'text' };
            when $_ ∈ <gpt-3.5-turbo gpt-3.5-turbo-0301> { 'chat' };
            default { 'text' }
        }
    }
    die "The argument \$type is expected to be one of 'chat', 'text', or Whatever."
    unless $type ∈ <chat text>;

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model.isa(Whatever) { $model = $type eq 'text' ?? 'text-davinci-003' !! 'gpt-3.5-turbo'; }
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
our proto openai-chat-completion(|) is export {*}

multi sub openai-chat-completion(**@args, *%args) {
    return WWW::OpenAI::ChatCompletions::OpenAIChatCompletion(|@args, |%args);
}

#===========================================================
#| OpenAI embeddings access.
our proto openai-embeddings(|) is export {*}

multi sub openai-embeddings(**@args, *%args) {
    return WWW::OpenAI::Embeddings::OpenAIEmbeddings(|@args, |%args);
}

#===========================================================
#| OpenAI image generation access.
our proto openai-create-image(|) is export {*}

multi sub openai-create-image(**@args, *%args) {
    return WWW::OpenAI::ImageGenerations::OpenAICreateImage(|@args, |%args);
}

#===========================================================
#| OpenAI models access.
our proto openai-models(|) is export {*}

multi sub openai-models(*%args) {
    return WWW::OpenAI::Models::OpenAIModels(|%args);
}

#===========================================================
#| OpenAI moderations access.
our proto openai-moderation(|) is export {*}

multi sub openai-moderation(**@args, *%args) {
    return WWW::OpenAI::Moderations::OpenAIModeration(|@args, |%args);
}

#===========================================================
#| OpenAI text completions access.
our proto openai-text-completion(|) is export {*}

multi sub openai-text-completion(**@args, *%args) {
    return WWW::OpenAI::TextCompletions::OpenAITextCompletion(|@args, |%args);
}

#============================================================
# Playground
#============================================================

#| OpenAI playground access.
our proto openai-playground($text is copy = '',
                            Str :$path = 'completions',
                            :$auth-key is copy = Whatever,
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
                            :$auth-key is copy = Whatever,
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
            my $expectedKeys = <model prompt suffix max-tokens temperature top-n n stream echo presence-penalty frequency-penalty best-of>;
            return openai-text-completion($text,
                    |%args.grep({ $_.key ∈ $expectedKeys }).Hash,
                    :$auth-key, :$timeout, :$format, :$method);
        }
        when $_ ∈ <create-image image-generation image-generations images-generations images/generations> {
            # my $url = 'https://api.openai.com/v1/images/generations';
            return openai-create-image($text, |%args.grep({ $_.key ∈ <n response-format size> }).Hash, :$auth-key,
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