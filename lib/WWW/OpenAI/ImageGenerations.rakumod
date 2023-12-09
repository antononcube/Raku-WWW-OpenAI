use v6.d;

use WWW::OpenAI::Request;
use WWW::OpenAI::Models;
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
                            :$model is copy = Whatever,
                            UInt :$n = 1,
                            :$response-format is copy = Whatever,
                            :$size is copy = Whatever,
                            :$style is copy = Whatever,
                            :api-key(:$auth-key) is copy = Whatever,
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
                            :$model is copy = Whatever,
                            UInt :$n = 1,
                            :$response-format is copy = Whatever,
                            :$size is copy = Whatever,
                            :$style is copy = Whatever,
                            :api-key(:$auth-key) is copy = Whatever,
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
    my %sizeMap2 = small => '256x256', medium => '512x512', 'large' => '1024x1024';
    %sizeMap2 = %sizeMap2, %sizeMap2.values.map({ $_ => $_ }).Hash;

    my %sizeMap3 = square => '1024x1024', landscape => '1792x1024', 'portrait' => '1024x1792';
    %sizeMap3 = %sizeMap3, %sizeMap3.values.map({ $_ => $_ }).Hash;

    die "The argument \$size is expected to be Whatever or one of '{ [|%sizeMap2.keys, |%sizeMap3.keys].sort.join(', ') }'."
    unless $size.isa(Whatever) || (%sizeMap2{$size}:exists) || (%sizeMap3{$size}:exists);

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model ~~ Str && $model.lc ∈ <dalle2 dall-e2 dall-e-2> { $model = 'dall-e-2'; }
    if $model ~~ Str && $model.lc ∈ <dalle3 dall-e3 dall-e-3> { $model = 'dall-e-3'; }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-end-point-to-models('/v1/images/generations').join('", "') ~ '"' }."
    unless $model.isa(Whatever) || $model ∈ openai-end-point-to-models('/v1/images/generations');

    #------------------------------------------------------
    # Assign and check appropriate $model and $size values
    #------------------------------------------------------
    if $model.isa(Whatever) && $size.isa(Whatever) {
        if $n > 1 {
            $model = 'dall-e-2'; $size = 'small';
        } else {
            $model = 'dall-e-3'; $size = 'square';
        }
    } elsif $model.isa(Whatever) && (%sizeMap2{$size}:exists) {
        $model = 'dall-e-2';
    } elsif $model.isa(Whatever) && (%sizeMap3{$size}:exists) {
        if $n == 1 {
            $model = 'dall-e-3';
        } else {
            die "The image size value $size implies the use of the model \"dall-e-3\"," ~
                    "and that model can generate one image only. (Not $n.)";
        }
    } elsif $model eq 'dall-e-2' && $size.isa(Whatever) {
        $size = %sizeMap2<small>;
    } elsif $model eq 'dall-e-2' && !(%sizeMap2{$size}:exists) {
        die "When the model is $model then \$size is expected to be Whatever or one of '{ %sizeMap2.keys.sort.join(', ') }'.";
    } elsif $model eq 'dall-e-3' && $n > 1 {
        die "The model \"dall-e-3\" can generate one image only. (Not $n.)";
    } elsif $model eq 'dall-e-3' && $size.isa(Whatever) {
        $size = %sizeMap3<square>;
    } elsif $model eq 'dall-e-3' && !(%sizeMap3{$size}:exists) {
        die "When the model is $model then \$size is expected to be Whatever or one of '{ %sizeMap3.keys.sort.join(', ') }'.";
    }

    $size = %sizeMap3{$size} // %sizeMap2{$size} // $size;

    #------------------------------------------------------
    # Process $style
    #------------------------------------------------------
    if $style.isa(Whatever) { $style = 'vivid'; }
    die "The argument \$style is expected to be Whatever or one of 'vivid' or 'natural'."
    unless $style ~~ Str && $style.lc ∈ <vivid natural>;

    #------------------------------------------------------
    # Process $format
    #------------------------------------------------------
    my Bool $asMDImage = False;
    if $format ~~ Str && $format.lc ∈ <image md-image> {
        $asMDImage = $format.lc eq 'md-image';
        $response-format = 'b64_json';
        $format = 'values';
    }

    #------------------------------------------------------
    # Process $response_format
    #------------------------------------------------------
    if $response-format.isa(Whatever) { $response-format = 'url'; }
    die "The argument \$response_format is expected to be Whatever or one of 'url' or 'b64_json'."
    unless $response-format ∈ <url b64_json>;

    #------------------------------------------------------
    # Make OpenAI URL
    #------------------------------------------------------

    my %body = :$model, :$prompt, :$size, :$style, response_format => $response-format, :$n;

    my $url = 'https://api.openai.com/v1/images/generations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    my $res = openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);

    if $asMDImage && $res ~~ Iterable && $res.all ~~ Str {
        $res = $res.map({ '![](data:image/png;base64,' ~ $_ ~ ')' });
    }

    return $res;
}
