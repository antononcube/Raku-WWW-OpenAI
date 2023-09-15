use v6.d;

use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::ImageGenerations;

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

#| OpenAI image generation access.
our proto OpenAICreateImage($prompt,
                            UInt :$n = 1,
                            :$size is copy = Whatever,
                            :$response-format is copy = Whatever,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny'
                            ) is export {*}

#| OpenAI image generation access.
multi sub OpenAICreateImage(@prompts, *%args) {
    return @prompts.map({ OpenAICreateImage($_, |%args) });
}

#| OpenAI image generation access.
multi sub OpenAICreateImage($prompt,
                            UInt :$n = 1,
                            :$size is copy = Whatever,
                            :$response-format is copy = Whatever,
                            :$auth-key is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny') {

    #------------------------------------------------------
    # Process $n
    #------------------------------------------------------
    die "The argument \$n is expected to be a positive integer between 1 and 10."
    unless 0 < $n ≤ 10;

    #------------------------------------------------------
    # Process $size
    #------------------------------------------------------
    if $size.isa(Whatever) { $size = '256x256'; }
    my %sizeMap = small => '256x256', medium => '512x512', 'large' => '1024x1024';
    %sizeMap = %sizeMap, %sizeMap.values.map({ $_ => $_ }).Hash;

    die "The argument \$size is expected to be Whatever or one of '{ %sizeMap.keys.sort.join(', ') }'."
    unless %sizeMap{$size}:exists;
    $size = %sizeMap{$size};

    #------------------------------------------------------
    # Process $response_format
    #------------------------------------------------------
    if $response-format.isa(Whatever) { $response-format = 'url'; }
    die "The argument \$response_format is expected to be Whatever or one of 'url' or 'b64_json'."
    unless $response-format ∈ <url b64_json>;

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my %body = :$prompt, :$size, response_format => $response-format, :$n;

    my $url = 'https://api.openai.com/v1/images/generations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);
}
