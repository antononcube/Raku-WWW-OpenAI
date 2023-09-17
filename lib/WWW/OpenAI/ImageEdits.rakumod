use v6.d;

use WWW::OpenAI::Request;
use JSON::Fast;

unit module WWW::OpenAI::ImageEdits;

#============================================================
# Images generation
#============================================================

my $imageEditStencil = q:to/END/;
{
  "prompt": "$prompt"
  "image": "@$imageFileName",
  "mask": "@$maskImageFileName",
  "n": $n,
  "size": "$size",
  "response_format" : "$response-format"
}
END

#| OpenAI image generation access.
our proto OpenAIEditImage($imageFile,
                          Str $prompt,
                          :$mask-file = Whatever,
                          UInt :$n = 1,
                          :$size is copy = Whatever,
                          :$response-format is copy = Whatever,
                          :api-key(:$auth-key) is copy = Whatever,
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          Str :$method = 'tiny'
                          ) is export {*}

#| OpenAI image generation access.
multi sub OpenAIEditImage(@fileNames, Str $prompt, *%args) {
    return @fileNames.map({ OpenAIEditImage($_, $prompt, |%args) });
}

#| OpenAI image generation access.
multi sub OpenAIEditImage($file,
                          Str $prompt,
                          :$mask-file is copy = Whatever,
                          UInt :$n = 1,
                          :$size is copy = Whatever,
                          :$response-format is copy = Whatever,
                          :api-key(:$auth-key) is copy = Whatever,
                          UInt :$timeout= 10,
                          :$format is copy = Whatever,
                          Str :$method = 'tiny') {

    #------------------------------------------------------
    # Process $file
    #------------------------------------------------------
    die "The first argument is expected to be a file name of a PNG image."
    unless $file.IO.e;

    #------------------------------------------------------
    # Process $mask-file
    #------------------------------------------------------
    if $mask-file.isa(Whatever) { $mask-file = ''; }
    die "The argument \$mask-file is expected to be a file name of a PNG image, empty string, or Whatever."
    unless $mask-file ~~ Str:D && !$mask-file || $mask-file.IO.e;

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

    my $url = 'https://api.openai.com/v1/images/edits';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------
    if $method eq 'curl' {
        # Some sort of no-good shortcut -- see curl-post
        my %body = image => $file, mask => $mask-file, :$prompt, :$size, :$n, response_format => $response-format;

        return openai-request(:$url, :%body, :$auth-key, :$timeout, :$format, :$method);

    } elsif $method eq 'tiny' {

        my %body = :$prompt, :$size, :$n, response_format => $response-format;

        %body<image> = $file.IO;
        if $mask-file {
            %body<mask> = $mask-file.IO;
        }

        return openai-request(:$url, :%body, :$auth-key, :$timeout, :$format, :$method);

    }
}
