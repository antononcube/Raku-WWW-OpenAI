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
                            :$quality is copy = Whatever,
                            :$response-format is copy = Whatever,
                            :$size is copy = Whatever,
                            :$style is copy = Whatever,
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            Str :$base-url = 'https://api.openai.com/v1'
                            ) is export {*}

#| OpenAI image generation access.
multi sub OpenAICreateImage(@prompts, *%args) {
    return @prompts.map({ OpenAICreateImage($_, |%args) });
}

#| OpenAI image generation access.
multi sub OpenAICreateImage($prompt,
                            :$model is copy = Whatever,
                            UInt :$n = 1,
                            :$quality is copy = Whatever,
                            :$response-format is copy = Whatever,
                            :$size is copy = Whatever,
                            :$style is copy = Whatever,
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            Str :$base-url = 'https://api.openai.com/v1') {

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

    my %sizeMapGPT = :default("auto"),
                     :square("1024x1024"), :landscape("1536x1024"), :portrait("1024x1536"),
                     "2K landscape" => "2048x1152", "4K portrait" => "2160x3840",
                     "4K landscape" => "3840x2160",  "2K square" => "2048x2048";

    die "The argument \$size is expected to be Whatever or one of '{ [|%sizeMap2.keys, |%sizeMap3.keys, |%sizeMapGPT.keys].sort.join(', ') }'."
    unless $size.isa(Whatever) || (%sizeMap2{$size}:exists) || (%sizeMap3{$size}:exists) || (%sizeMapGPT{$size});

    #------------------------------------------------------
    # Process $model
    #------------------------------------------------------
    if $model ~~ Str && $model.lc ∈ <dalle2 dall-e2 dall-e-2> { $model = 'dall-e-2'; }
    if $model ~~ Str && $model.lc ∈ <dalle3 dall-e3 dall-e-3> { $model = 'dall-e-3'; }
    if $model ~~ Str && $model.lc ~~ / ^ ['gpt-image-' | 'chatgpt-image-'] / { $model .= lc  }
    if $model.isa(Whatever) { $model = WWW::OpenAI::Models::GetDefaultModel(:image-generation); }
    die "The argument \$model is expected to be Whatever or one of the strings: { '"' ~ openai-end-point-to-models('/v1/images/generations').join('", "') ~ '"' }."
    unless $model.isa(Whatever) || $model ∈ openai-end-point-to-models('/v1/images/generations');

    #------------------------------------------------------
    # Assign and check appropriate $model and $size values
    #------------------------------------------------------
    if $model eq 'dall-e-2' && $size.isa(Whatever) {
        $size = %sizeMap2<small>;
    } elsif $model eq 'dall-e-2' && !(%sizeMap2{$size}:exists) {
        die "When the model is $model then \$size is expected to be Whatever or one of '{ %sizeMap2.keys.sort.join(', ') }'.";
    } elsif $model eq 'dall-e-3' && $n > 1 {
        die "The model \"dall-e-3\" can generate one image only. (Not $n.)";
    } elsif $model eq 'dall-e-3' && $size.isa(Whatever) {
        $size = %sizeMap3<square>;
    } elsif $model eq 'dall-e-3' && !(%sizeMap3{$size}:exists) {
        die "When the model is $model then \$size is expected to be Whatever or one of '{ %sizeMap3.keys.sort.join(', ') }'.";
    } elsif $model.starts-with('gpt-image') {
        die "When the model is $model then \$size must be a GPT Image size or Whatever."
        unless $size.isa(Whatever) || (%sizeMapGPT{$size}:exists) || $size eq 'auto';
        $size = $size.isa(Whatever) ?? 'auto' !! %sizeMapGPT{$size} // $size;
    } else {
        $size = %sizeMap3{$size} // %sizeMap2{$size} // %sizeMapGPT{$size} // $size;
    }

    #------------------------------------------------------
    # Process $style
    #------------------------------------------------------
    if $style.isa(Whatever) { $style = 'vivid'; }
    die "The argument \$style is expected to be Whatever or one of 'vivid' or 'natural'."
    unless $style ~~ Str && $style.lc ∈ <vivid natural>;

    #------------------------------------------------------
    # Process $quality
    #------------------------------------------------------
    if $quality.isa(Whatever) {
        $quality = $model.starts-with('dall-e') ?? 'standard' !!
                $model.starts-with('gpt-image-2.6-') ?? 'auto' !! 'medium';
    }
    my @expectedQuality = $model.starts-with('dall-e') ?? <hd standard> !!
            $model.starts-with('gpt-image-2.6-') ?? <auto low medium high xhigh max> !! <auto low medium high>;
    die "The quality '$quality' is not supported by model '$model'."
    unless $quality ~~ Str && $quality.lc ∈ @expectedQuality;

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

    my %body = :$model, :$prompt, :$size, :$n;

    if $model eq 'dall-e-3' {
        %body = %body , {:$style}
    }

    if $model ne 'dall-e-2' {
        %body = %body , {:$quality}
    }

    if $model ∈ <dall-e-2 dall-e-3> {
        %body = %body , {response_format => $response-format}
    }

    my $url = $base-url ~ '/images/generations';

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    my $res = openai-request(:$url, body => to-json(%body), :$auth-key, :$timeout, :$format, :$method);

    if $asMDImage && $res ~~ Iterable && $res.all ~~ Str {
        $res = $res.map({ '![](data:image/png;base64,' ~ $_ ~ ')' });
    }

    return $res;
}
