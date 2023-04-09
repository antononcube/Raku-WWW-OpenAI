# Image generation

This Markdown file can be "evaluated" with the Raku package "Text::CodeProcessing", [AAp2]. 
Here is a shell command:

```
file-code-chunks-eval Image-generation.md 
```

Here we load the Raku package "WWW::OpenAI", [AAp1]:

```perl6
use WWW::OpenAI;
```

Images can be generated with the function `openai-create-image` -- see the section
["Images"](https://platform.openai.com/docs/api-reference/images) of [OAI2].

Here is an example that returns the whole image in a [Base64 format](https://en.wikipedia.org/wiki/Base64):

```perl6, results=asis
my @imgResB64 = |openai-create-image(
        "racoon with a sliced onion in the style of Raphael",
        n => 2,
        size => 'small',
        response-format => 'b64_json',
        format => 'values',
        method => 'tiny');

@imgResB64.map({ '![](data:image/png;base64,' ~ $_ ~ ')' }).join("\n\n")        
```

**Remark:** The obtained images are put into the *woven* document via the output of the code cell, 
which has the setting `results=asis`.

The first argument is a *prompt* used to generate the image(s).

Here are the descriptions of the named arguments (options):

- `n` takes a positive integer, for the number of images to be generated
- `size` takes the values '1024x1024', '512x512', '256x256', 'large', 'medium', 'small'.
- `response-format` takes the values "url" and "b64_json"
- `method` takes the values "tiny" and "curl"


Here we generate a few images, get their URLs, and place (embed) the image links using a table:

```perl6, results=asis
my @imgRes = |openai-create-image(
        "racoon and onion in the style of Rene Magritte",
        response-format => 'url',
        n => 2,
        size => 'small',
        format => 'values',
        method => 'tiny');

@imgRes.map({ '![](' ~ $_ ~ ')' }).join("\n\n")       
```

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