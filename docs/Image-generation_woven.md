# Image generation

The examples below document the earlier DALL·E models. For new requests, the
package defaults to `gpt-image-2.6-flare`. For example:

```raku, results=asis
use WWW::OpenAI;
my @images = openai-create-image(
    'A raccoon reading a Raku book',
    size => 'square',
    format => 'values');  # Base64 image data

@images.map({ '![](data:image/png;base64,' ~ $_ ~ ')' }).join("\n\n") 
```

<hr style="width: 60%; height: 6px; margin: 1rem auto; border: 0; background-color: currentColor;">

The DALL·E examples below are historical: OpenAI has shut down `dall-e-2` and
`dall-e-3`. See [OpenAI deprecations](https://developers.openai.com/api/docs/deprecations).

<hr style="width: 60%; height: 6px; margin: 1rem auto; border: 0; background-color: currentColor;">

This Markdown file can be "evaluated" with the Raku package "Text::CodeProcessing", [AAp2]. 
Here is a shell command:

```
file-code-chunks-eval Image-generation.md 
```

**Remark:** For doing image *variations* using image files see the document
[Image-variation-and-edition.md](./Image-variation-and-edition.md)
(and its woven version, [Image-variation-and-edition_woven.md](./Image-variation-and-edition_woven.md).)


Here we load the Raku package "WWW::OpenAI", [AAp1]:

```raku
use WWW::OpenAI;
```
```
# (Any)
```

Images can be generated with the function `openai-create-image` -- see the section
["Images"](https://platform.openai.com/docs/api-reference/images) of [OAI2].

Here is an example that returns "whole images" in [Base64 format](https://en.wikipedia.org/wiki/Base64):

```raku, results=asis
my @imgResB64 = |openai-create-image(
        "raccoon with a sliced onion in the style of Raphael",
        model => 'dall-e-3',
        n => 1,
        size => 'square',
        response-format => 'b64_json',
        format => 'values',
        method => 'tiny');

@imgResB64.map({ '![](data:image/png;base64,' ~ $_ ~ ')' }).join("\n\n")        
```
#ERROR: error	code	unknown_parameter
#ERROR: message	Unknown parameter: 'response_format'.
#ERROR: param	response_format
#ERROR: type	invalid_request_error
Nil


**Remark:** The obtained images are put into the *woven* document via the output of the code cell, 
which has the setting `results=asis`.

The first argument is a *prompt* used to generate the image(s).

Here are the descriptions of the named arguments (options):

- `model` takes `Whatever`, or one of 'dall-e-2' or 'dall-e-3'
- `n` takes a positive integer, for the number of images to be generated
- `size` takes the values according to the `model` value:
  - 'dall-e-2' : '1024x1024', '512x512', '256x256', 'large', 'medium', 'small'
  - 'dall-e-3' : '1024x1024', '1792x1024', '1024x1792', 'square', 'portrait', 'landscape'
- `response-format` takes the values "url" and "b64_json"
- `method` takes the values "tiny" and "curl"

**Remark:** See the model-parameter breakdown in the section below. 

Here we generate a few images, get their URLs, and place (embed) the image links using a table:

```raku, results=asis
my @imgRes = |openai-create-image(
        "painting of a racoon and onion in the style of Rene Magritte",
        response-format => 'url',
        n => 2,
        size => 'small',
        format => 'values',
        method => 'tiny');

@imgRes.map({ '![](' ~ $_ ~ ')' }).join("\n\n")       
```
#ERROR: When the model is gpt-image-2.6-flare then $size must be a GPT Image size or Whatever.
Nil


-----

## Parameters

As it was mentioned above, the argument "model" can be `Whatever` of one of "dall-e-2" or "dall-e-3".

Not all parameters that are valid for one of the models are valid or respected by the other --
see the subsection ["Create image"](https://platform.openai.com/docs/api-reference/images/create) of
[OpenAI's documentation](https://platform.openai.com/docs/api-reference).

Here is a table that shows a breakdown of the model-parameter relationships:

| Parameter | Type | Required/Optional | Default | dall-e-2 | dall-e-3 | Valid Values |
|-----------|------|------------------|---------|----------|----------|--------------|
| prompt | string | Required | N/A | ✔️ | ✔️ | Maximum length is 1000 characters for dall-e-2 and 4000 characters for dall-e-3 |
| model | string | Optional | dall-e-2 | ✔️ | ✔️ | N/A |
| n | integer or null | Optional | 1 | ✔️ | ✔️ (only n=1) | Must be between 1 and 10. For dall-e-3, only n=1 is supported |
| quality | string | Optional | standard | ❌ | ✔️ | N/A |
| response_format | string or null | Optional | url | ✔️ | ✔️ | Must be one of url or b64_json |
| size | string or null | Optional | 1024x1024 | ✔️ (256x256, 512x512, 1024x1024) | ✔️ (1024x1024, 1792x1024, 1024x1792) | Must be one of 256x256, 512x512, or 1024x1024 for dall-e-2. Must be one of 1024x1024, 1792x1024, or 1024x1792 for dall-e-3 models |
| style | string or null | Optional | vivid | ❌ | ✔️ | Must be one of vivid or natural |


--------

## References

### Articles

[AA1] Anton Antonov,
["Connecting Mathematica and Raku"](https://rakuforprediction.wordpress.com/2021/12/30/connecting-mathematica-and-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

### Packages

[AAp1] Anton Antonov,
[WWW::OpenAI Raku package](https://github.com/antononcube/Raku-WWW-OpenAI),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Text::CodeProcessing](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[OAI1] OpenAI Platform, [OpenAI platform](https://platform.openai.com/).

[OAI2] OpenAI Platform, [OpenAI documentation](https://platform.openai.com/docs).

[OAIp1] OpenAI,
[OpenAI Python Library](https://github.com/openai/openai-python),
(2020),
[GitHub/openai](https://github.com/openai/).
