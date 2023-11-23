# WWW::OpenAI Raku package

## In brief

This Raku package provides access to the machine learning service [OpenAI](https://platform.openai.com), [OAI1].
For more details of the OpenAI's API usage see [the documentation](https://platform.openai.com/docs/api-reference/making-requests), [OAI2].

**Remark:** To use the OpenAI API one has to register and obtain authorization key.

**Remark:** This Raku package is much "less ambitious" than the official Python package, [OAIp1], developed by OpenAI's team.
Gradually, over time, I expect to add features to the Raku package that correspond to features of [OAIp1].

The original design and implementation of "WWW::OpenAI" were very similar to those of
["Lingua::Translation::DeepL"](https://raku.land/zef:antononcube/Lingua::Translation::DeepL), [AAp1].
Major refactoring of the original code was done -- now each OpenAI functionality targeted by "WWW::OpenAI"
has its code placed in a separate file.

-----

## Installation

Package installations from both sources use [zef installer](https://github.com/ugexe/zef)
(which should be bundled with the "standard" Rakudo installation file.)

To install the package from [Zef ecosystem](https://raku.land/) use the shell command:

```
zef install WWW::OpenAI
```

To install the package from the GitHub repository use the shell command:

```
zef install https://github.com/antononcube/Raku-WWW-OpenAI.git
```

----

## Usage examples

**Remark:** When the authorization key, `auth-key`, is specified to be `Whatever`
then the functions `openai-*` attempt to use the env variable `OPENAI_API_KEY`.

### Universal "front-end"

The package has an universal "front-end" function `openai-playground` for the 
[different functionalities provided by OpenAI](https://platform.openai.com/docs/api-reference/introduction).

Here is a simple call for a "chat completion":

```perl6
use WWW::OpenAI;
openai-playground('Where is Roger Rabbit?', max-tokens => 64);
```
```
# [{finish_reason => stop, index => 0, logprobs => (Any), text => 
# 
# Roger Rabbit is a fictional character from the 1988 film "Who Framed Roger Rabbit." He is not a real person and therefore does not have a physical location.}]
```

Another one using Bulgarian:

```perl6
openai-playground('Колко групи могат да се намерят в този облак от точки.', max-tokens => 64);
```
```
# [{finish_reason => length, index => 0, logprobs => (Any), text => 
# 
# Този облак от точки може да бъде разделен на произволен брой групи, в зависимост от критериите, които се изберат за тяхното форми}]
```

**Remark:** The function `openai-completion` can be used instead in the examples above. 
See the section 
["Create chat completion"](https://platform.openai.com/docs/api-reference/chat/create) of [OAI2]
for more details.

### Models

The current OpenAI models can be found with the function `openai-models`:

```perl6
openai-models
```
```
# (ada ada-code-search-code ada-code-search-text ada-search-document ada-search-query ada-similarity babbage babbage-002 babbage-code-search-code babbage-code-search-text babbage-search-document babbage-search-query babbage-similarity canary-tts canary-whisper code-davinci-edit-001 code-search-ada-code-001 code-search-ada-text-001 code-search-babbage-code-001 code-search-babbage-text-001 curie curie-instruct-beta curie-search-document curie-search-query curie-similarity dall-e-2 davinci davinci-002 davinci-instruct-beta davinci-search-document davinci-search-query davinci-similarity gpt-3.5-turbo gpt-3.5-turbo-0301 gpt-3.5-turbo-0613 gpt-3.5-turbo-1106 gpt-3.5-turbo-16k gpt-3.5-turbo-16k-0613 gpt-3.5-turbo-instruct gpt-3.5-turbo-instruct-0914 gpt-4 gpt-4-0314 gpt-4-0613 gpt-4-1106-preview gpt-4-vision-preview text-ada-001 text-babbage-001 text-curie-001 text-davinci-001 text-davinci-002 text-davinci-003 text-davinci-edit-001 text-embedding-ada-002 text-search-ada-doc-001 text-search-ada-query-001 text-search-babbage-doc-001 text-search-babbage-query-001 text-search-curie-doc-001 text-search-curie-query-001 text-search-davinci-doc-001 text-search-davinci-query-001 text-similarity-ada-001 text-similarity-babbage-001 text-similarity-curie-001 text-similarity-davinci-001 tts-1 tts-1-1106 tts-1-hd tts-1-hd-1106 whisper-1)
```

### Code generation

There are two types of completions : text and chat. Let us illustrate the differences
of their usage by Raku code generation. Here is a text completion:

```perl6
openai-completion(
        'generate Raku code for making a loop over a list',
        type => 'text',
        max-tokens => 120,
        format => 'values');
```
```
# my @list = (1, 2, 3, 4, 5);
# 
# for @list -> $item {
#     # do something with $item
# }
```

Here is a chat completion:

```perl6
openai-completion(
        'generate Raku code for making a loop over a list',
        type => 'chat',
        max-tokens => 120,
        format => 'values');
```
```
# Sure! Here's an example of Raku code that creates a loop over a list:
# 
# ```raku
# my @list = <apple banana cherry>;
# 
# for @list -> $item {
#     say $item;
# }
# ```
# 
# In this code, we have a list `@list` containing three elements: `apple`, `banana`, and `cherry`. The `for` loop iterates over each element in the list, assigning it to the `$item` variable, and then prints the value of `$item` using the `say` function.
```

**Remark:** The argument "type" and the argument "model" have to "agree." (I.e. be found agreeable by OpenAI.)
For example: 
- `model => 'text-davinci-003'` implies `type => 'text'`
- `model => 'gpt-3.5-turbo'` implies `type => 'chat'`


### Image generation

**Remark:** See the files ["Image-generation*"](./docs/Image-generation.md) for more details.

Images can be generated with the function `openai-create-image` -- see the section
["Images"](https://platform.openai.com/docs/api-reference/images) of [OAI2].

Here is an example:

```perl6, eval=FALSE
my $imgB64 = openai-create-image(
        "racoon with a sliced onion in the style of Raphael",
        response-format => 'b64_json',
        n => 1,
        size => 'small',
        format => 'values',
        method => 'tiny');
```

Here are the options descriptions:

- `response-format` takes the values "url" and "b64_json"
- `n` takes a positive integer, for the number of images to be generated
- `size` takes the values '1024x1024', '512x512', '256x256', 'large', 'medium', 'small'. 

Here we generate an image, get its URL, and place (embed) a link to it via the output of the code cell:

```perl6, results='asis', eval=FALSE
my @imgRes = |openai-create-image(
        "racoon and onion in the style of Roy Lichtenstein",
        response-format => 'url',
        n => 1,
        size => 'small',
        method => 'tiny');

'![](' ~ @imgRes.head<url> ~ ')';
```

### Image variation

**Remark:** See the files ["Image-variation*"](./docs/Image-variation-and-edition.md) for more details.

Images variations over image files can be generated with the function `openai-variate-image` 
-- see the section
["Images"](https://platform.openai.com/docs/api-reference/images) of [OAI2].

Here is an example:

```perl6, eval=FALSE
my $imgB64 = openai-variate-image(
        $*CWD ~ '/resources/RandomMandala.png',
        response-format => 'b64_json',
        n => 1,
        size => 'small',
        format => 'values',
        method => 'tiny');
```

Here are the options descriptions:

- `response-format` takes the values "url" and "b64_json"
- `n` takes a positive integer, for the number of images to be generated
- `size` takes the values '1024x1024', '512x512', '256x256', 'large', 'medium', 'small'.

**Remark:** Same arguments are used by `openai-generate-image`. See the previous sub-section.

Here we generate an image, get its URL, and place (embed) a link to it via the output of the code cell:

```perl6, results='asis', eval=FALSE
my @imgRes = |openai-variate-image(
        $*CWD ~ '/resources/RandomMandala.png',
        response-format => 'url',
        n => 1,
        size => 'small',
        method => 'tiny');

'![](' ~ @imgRes.head<url> ~ ')';
```

## Image edition

**Remark:** See the files ["Image-variation*"](./docs/Image-variation-and-edition.md) for more details.

Editions of images can be generated with the function `openai-edit-image` -- see the section
["Images"](https://platform.openai.com/docs/api-reference/images) of [OAI2].

Here are the descriptions of positional arguments:

- `file` is a file name string (a PNG image with [RGBA color space](https://en.wikipedia.org/wiki/RGBA_color_model))
- `prompt` is a prompt tha describes the image edition

Here are the descriptions of the named arguments (options):

- `mask-file` a file name of a mask image (can be an empty string or `Whatever`)
- `n` takes a positive integer, for the number of images to be generated
- `size` takes the values '1024x1024', '512x512', '256x256', 'large', 'medium', 'small'.
- `response-format` takes the values "url" and "b64_json"
- `method` takes the values "tiny" and "curl"

Here is a random mandala color (RGBA) image:

![](../resources/RandomMandala2.png)

Here we generate a few editions of the colored mandala image above, get their URLs,
and place (embed) the image links using a table:

```perl6, results=asis, eval=FALSE
my @imgRes = |openai-edit-image(
        $*CWD ~ '/../resources/RandomMandala2.png',
        'add cosmic background',
        response-format => 'url',
        n => 2,
        size => 'small',
        format => 'values',
        method => 'tiny');

@imgRes.map({ '![](' ~ $_ ~ ')' }).join("\n\n")       
```

### Moderation

Here is an example of using 
[OpenAI's moderation](https://platform.openai.com/docs/api-reference/moderations):

```perl6
my @modRes = |openai-moderation(
"I want to kill them!",
format => "values",
method => 'tiny');

for @modRes -> $m { .say for $m.pairs.sort(*.value).reverse; }
```
```
# violence => 0.9961207509040833
# harassment => 0.6753228306770325
# harassment/threatening => 0.6230513453483582
# hate => 0.12013232707977295
# hate/threatening => 0.019687965512275696
# sexual => 3.780321264912345e-07
# sexual/minors => 8.417104879754334e-08
# violence/graphic => 7.003104940395133e-08
# self-harm => 3.3011907096813786e-10
# self-harm/intent => 4.843588724545711e-11
# self-harm/instructions => 3.1562556387920715e-13
```

### Audio transcription and translation

Here is an example of using
[OpenAI's audio transcription](https://platform.openai.com/docs/api-reference/audio):

```perl6
my $fileName = $*CWD ~ '/resources/HelloRaccoonsEN.mp3';
say openai-audio(
        $fileName,
        format => 'json',
        method => 'tiny');
```
```
# {
#   "text": "Raku practitioners around the world, eat more onions!"
# }
```

To do translations use the named argument `type`:

```perl6
my $fileName = $*CWD ~ '/resources/HowAreYouRU.mp3';
say openai-audio(
        $fileName,
        type => 'translations',
        format => 'json',
        method => 'tiny');
```
```
# {
#   "text": "How are you, bandits, hooligans? I have long gone mad from you. I have been working as a guard all my life."
# }
```

### Embeddings

[Embeddings](https://platform.openai.com/docs/api-reference/embeddings)
can be obtained with the function `openai-embeddings`. Here is an example of finding the embedding vectors
for each of the elements of an array of strings:

```perl6
my @queries = [
    'make a classifier with the method RandomForeset over the data dfTitanic',
    'show precision and accuracy',
    'plot True Positive Rate vs Positive Predictive Value',
    'what is a good meat and potatoes recipe'
];

my $embs = openai-embeddings(@queries, format => 'values', method => 'tiny');
$embs.elems;
```
```
# 4
```

Here we show:
- That the result is an array of four vectors each with length 1536
- The distributions of the values of each vector

```perl6
use Data::Reshapers;
use Data::Summarizers;

say "\$embs.elems : { $embs.elems }";
say "\$embs>>.elems : { $embs>>.elems }";
records-summary($embs.kv.Hash.&transpose);
```
```
# $embs.elems : 4
# $embs>>.elems : 1536 1536 1536 1536
# +--------------------------------+------------------------------+--------------------------------+------------------------------+
# | 1                              | 0                            | 2                              | 3                            |
# +--------------------------------+------------------------------+--------------------------------+------------------------------+
# | Min    => -0.6675609           | Min    => -0.5905979         | Min    => -0.6316688           | Min    => -0.60487235        |
# | 1st-Qu => -0.0122597895        | 1st-Qu => -0.013208558       | 1st-Qu => -0.012534879         | 1st-Qu => -0.0129462655      |
# | Mean   => -0.00076258629791471 | Mean   => -0.000762066322233 | Mean   => -0.00072970771235612 | Mean   => -0.000754160801387 |
# | Median => -0.000313577955      | Median => -0.0010125666      | Median => -0.00061200845       | Median => -0.00072666709     |
# | 3rd-Qu => 0.0111436975         | 3rd-Qu => 0.0123315665       | 3rd-Qu => 0.0118897265         | 3rd-Qu => 0.012172342        |
# | Max    => 0.22817883           | Max    => 0.2120242          | Max    => 0.21271802           | Max    => 0.22197673         |
# +--------------------------------+------------------------------+--------------------------------+------------------------------+
```

Here we find the corresponding dot products and (cross-)tabulate them:

```perl6
use Data::Reshapers;
use Data::Summarizers;
my @ct = (^$embs.elems X ^$embs.elems).map({ %( i => $_[0], j => $_[1], dot => sum($embs[$_[0]] >>*<< $embs[$_[1]])) }).Array;

say to-pretty-table(cross-tabulate(@ct, 'i', 'j', 'dot'), field-names => (^$embs.elems)>>.Str);
```
```
# +---+----------+----------+----------+----------+
# |   |    0     |    1     |    2     |    3     |
# +---+----------+----------+----------+----------+
# | 0 | 1.000000 | 0.724735 | 0.756752 | 0.665397 |
# | 1 | 0.724735 | 1.000000 | 0.811177 | 0.715478 |
# | 2 | 0.756752 | 0.811177 | 1.000000 | 0.698925 |
# | 3 | 0.665397 | 0.715478 | 0.698925 | 1.000000 |
# +---+----------+----------+----------+----------+
````

**Remark:** Note that the fourth element (the cooking recipe request) is an outlier.
(Judging by the table with dot products.)

### Vision

In the fall of 2023 OpenAI introduced image vision model 
["gpt-4-vision-preview"](https://openai.com/blog/new-models-and-developer-products-announced-at-devday), [OAIb1].

If the function `openai-completion` is given a list of images, textual results corresponding to those images is returned.
The argument "images" is a list of image URLs, image file names, or image Base64 representations. (Any combination of those element types.)

Here is 

```perl6
my $url1 = 'https://i.imgur.com/LEGfCeq.jpg';
my $url2 = 'https://i.imgur.com/UcRYl9Y.jpg';
my $fname3 = $*CWD ~ '/resources/ThreeHunters.jpg';
my @images = [$url1, $url2, $fname3];
say openai-completion("Give concise descriptions of the images.", :@images, max-tokens => 900, format => 'values');
```
```
# Image 1: A vibrantly colored illustration of a raccoon on a tree branch surrounded by a swarm of butterflies in various colors.
# 
# Image 2: An artwork depicting two raccoons on a pathway lined with trees, with butterflies in the air and a detailed tree featuring a sign and fruits on the ground.
# 
# Image 3: A painting showing three raccoons in a forest setting with a warm, glowing background, surrounded by butterflies and lush foliage.
```

The function `encode-image` from the namespace `WWW::OpenAI::ChatCompletions` can be used
to get Base64 image strings corresponding to image files. For example:

```perl6, results=asis, eval=FALSE
my $img3 = WWW::OpenAI::ChatCompletions::encode-image($fname3);
say "![]($img3)"  
```

When a file name is given to the argument "images" of `openai-completion` then the function `encode-image` is applied to it.


### Chat completions with engineered prompts

Here is a prompt for "emojification" (see the
[Wolfram Prompt Repository](https://resources.wolframcloud.com/PromptRepository/)
entry
["Emojify"](https://resources.wolframcloud.com/PromptRepository/resources/Emojify/)):

```perl6
my $preEmojify = q:to/END/;
Rewrite the following text and convert some of it into emojis.
The emojis are all related to whatever is in the text.
Keep a lot of the text, but convert key words into emojis.
Do not modify the text except to add emoji.
Respond only with the modified text, do not include any summary or explanation.
Do not respond with only emoji, most of the text should remain as normal words.
END
```
```
# Rewrite the following text and convert some of it into emojis.
# The emojis are all related to whatever is in the text.
# Keep a lot of the text, but convert key words into emojis.
# Do not modify the text except to add emoji.
# Respond only with the modified text, do not include any summary or explanation.
# Do not respond with only emoji, most of the text should remain as normal words.
```

Here is an example of chat completion with emojification:

```perl6
openai-chat-completion([ system => $preEmojify, user => 'Python sucks, Raku rocks, and Perl is annoying'], max-tokens => 200, format => 'values')
```
```
# 🐍 Python 🚫, 🪨 Raku 🤘, and Perl 😒 are 🤬.
```

For more examples see the document ["Chat-completion-examples"](./docs/Chat-completion-examples_woven.md).

### Finding textual answers

The models of OpenAI can be used to find sub-strings in texts that appear to be
answers to given questions. This is done via the package 
["ML::FindTextualAnswer"](https://raku.land/zef:antononcube/ML::FindTextualAnswer), [AAp3],
using the parameter specs `llm => 'chatgpt'` or `llm => 'openai'`.


Here is an example of finding textual answers:

```perl6
use ML::FindTextualAnswer;
my $text = "Lake Titicaca is a large, deep lake in the Andes 
on the border of Bolivia and Peru. By volume of water and by surface 
area, it is the largest lake in South America";

find-textual-answer($text, "Where is Titicaca?", llm => 'openai')
```
```
# Titicaca is on the border of Bolivia and Peru in the Andes.
```

By default `find-textual-answer` tries to give short answers.
If the option "request" is `Whatever` then depending on the number of questions 
the request is one those phrases:
- "give the shortest answer of the question:"
- "list the shortest answers of the questions:"

In the example above the full query given to OpenAI's models is:

> Given the text "Lake Titicaca is a large, deep lake in the Andes
on the border of Bolivia and Peru. By volume of water and by surface
area, it is the largest lake in South America" 
> give the shortest answer of the question:   
> Where is Titicaca?

Here we get a longer answer by changing the value of "request":

```perl6
find-textual-answer($text, "Where is Titicaca?", llm => 'chatgpt', request => "answer the question:")
```
```
# Titicaca is located in the Andes on the border of Bolivia and Peru.
```

**Remark:** The function `find-textual-answer` is inspired by the Mathematica function
[`FindTextualAnswer`](https://reference.wolfram.com/language/ref/FindTextualAnswer.html); 
see [JL1].

#### Multiple questions

If several questions are given to the function `find-textual-answer`
then all questions are spliced with the given text into one query (that is sent to OpenAI.)

For example, consider the following text and questions:

```perl6
my $query = 'Make a classifier with the method RandomForest over the data dfTitanic; show precision and accuracy.';

my @questions =
        ['What is the dataset?',
         'What is the method?',
         'Which metrics to show?'
        ];
```
```
# [What is the dataset? What is the method? Which metrics to show?]
```

Then the query send to OpenAI is:

> Given the text: "Make a classifier with the method RandomForest over the data dfTitanic; show precision and accuracy."
> list the shortest answers of the questions:   
> 1) What is the dataset?   
> 2) What is the method?    
> 3) Which metrics to show?   


The answers are assumed to be given in the same order as the questions, each answer in a separated line.
Hence, by splitting the OpenAI result into lines we get the answers corresponding to the questions.  

If the questions are missing question marks, it is likely that the result may have a completion as 
a first line followed by the answers. In that situation the answers are not parsed and a warning message is given.

-------

## Command Line Interface

### Playground access

The package provides a Command Line Interface (CLI) script:

```shell
openai-playground --help
```
```
# Usage:
#   openai-playground [<words> ...] [--path=<Str>] [-n[=UInt]] [--mt|--max-tokens[=UInt]] [-m|--model=<Str>] [-r|--role=<Str>] [-t|--temperature[=Real]] [-i|--images=<Str>] [-l|--language=<Str>] [--response-format=<Str>] [-a|--auth-key=<Str>] [--timeout[=UInt]] [-f|--format=<Str>] [--method=<Str>] -- Command given as a sequence of words.
#   
#     --path=<Str>                Path, one of 'chat/completions', 'images/generations', 'images/edits', 'images/variations', 'moderations', 'audio/transcriptions', 'audio/translations', 'embeddings', or 'models'. [default: 'chat/completions']
#     -n[=UInt]                   Number of completions or generations. [default: 1]
#     --mt|--max-tokens[=UInt]    The maximum number of tokens to generate in the completion. [default: 100]
#     -m|--model=<Str>            Model. [default: 'Whatever']
#     -r|--role=<Str>             Role. [default: 'user']
#     -t|--temperature[=Real]     Temperature. [default: 0.7]
#     -i|--images=<Str>           Image URLs or file names separated with comma (','). [default: '']
#     -l|--language=<Str>         Language. [default: '']
#     --response-format=<Str>     The format in which the generated images are returned; one of 'url' or 'b64_json'. [default: 'url']
#     -a|--auth-key=<Str>         Authorization key (to use OpenAI API.) [default: 'Whatever']
#     --timeout[=UInt]            Timeout. [default: 10]
#     -f|--format=<Str>           Format of the result; one of "json", "hash", "values", or "Whatever". [default: 'Whatever']
#     --method=<Str>              Method for the HTTP POST query; one of "tiny" or "curl". [default: 'tiny']
```

**Remark:** When the authorization key argument "auth-key" is specified set to "Whatever"
then `openai-playground` attempts to use the env variable `OPENAI_API_KEY`.


--------

## Mermaid diagram

The following flowchart corresponds to the steps in the package function `openai-playground`:

```mermaid
graph TD
	UI[/Some natural language text/]
	TO[/"OpenAI<br/>Processed output"/]
	WR[[Web request]]
	OpenAI{{https://platform.openai.com}}
	PJ[Parse JSON]
	Q{Return<br>hash?}
	MSTC[Compose query]
	MURL[[Make URL]]
	TTC[Process]
	QAK{Auth key<br>supplied?}
	EAK[["Try to find<br>OPENAI_API_KEY<br>in %*ENV"]]
	QEAF{Auth key<br>found?}
	NAK[/Cannot find auth key/]
	UI --> QAK
	QAK --> |yes|MSTC
	QAK --> |no|EAK
	EAK --> QEAF
	MSTC --> TTC
	QEAF --> |no|NAK
	QEAF --> |yes|TTC
	TTC -.-> MURL -.-> WR -.-> TTC
	WR -.-> |URL|OpenAI 
	OpenAI -.-> |JSON|WR
	TTC --> Q 
	Q --> |yes|PJ
	Q --> |no|TO
	PJ --> TO
```

--------

## Potential problems

### Tested on macOS only

Currently this package is tested on macOS only.

### Not all models work

Not all models listed and proclaimed by [OpenAI's documents](https://platform.openai.com/docs/models) 
work with the corresponding endpoints. Certain models are not available for text- or chat completions,
although the documentation says they are.

See and run the file ["Models-run-verification.raku"](./experiments/Models-run-verification.raku) 
to test the available models per endpoint.

Related is a (current) deficiency of the package "WWW::OpenAI" -- the known models are hardcoded.
(Although, there the function `openai-models` uses an endpoint provided by OpenAI.)

### SSL certificate problems (original package version)

*(This subsection is for the original version of the package, not for the most recent one.)*


- On macOS I get the errors:
    
  > Cannot locate symbol 'SSL_get1_peer_certificate' in native library

- See longer discussions about this problem 
  [here](https://stackoverflow.com/questions/72792280/macos-how-to-avoid-ssl-hell-on-intel-mac-with-raku)
  and
  [here](https://github.com/jnthn/p6-io-socket-async-ssl/issues/66)
  
- Interestingly: 
  - I did not get these messages while implementing the changes of ver<1.1> of this package
  - I do not get these messages when using Raku in Markdown or Mathematica notebooks, [AA1],
    via the package ["Text::CodeProcessing"](https://raku.land/zef:antononcube/Text::CodeProcessing)
  
- Because of those SSL problems I implemented the method option that takes the values 'cro' and 'curl'.
  
- The method "curl":
  - Requires [`curl`](https://curl.se) to be installed
  - Invokes the procedure [`shell`](https://docs.raku.org/routine/shell)
  - Again, this is tested on macOS only.  

- After "discovering" "HTTP::Tiny" and given the problems with "Cro::HTTP::Client", I removed the 'cro' method.
  (I.e. the methods are 'tiny' and 'curl' in ver<0.2.0+>.)
  
--------

## TODO

- [X] DONE Comprehensive unit tests
  - Note that this requires OpenAI auth token and costs money. (Ideally, not much.)
  - [X] DONE Basic usage
  - [X] DONE Completions - chat
  - [X] DONE Completions - text
  - [X] DONE Moderation
  - [X] DONE Audio transcription
  - [X] DONE Audio translation
  - [X] DONE Image generation
  - [X] DONE Image variation
  - [X] DONE Image edition
  - [X] DONE Embeddings
  - [X] DONE Finding of textual answers

- [X] DONE HTTP(S) retrieval methods

  - [X] DONE `curl`
  - [X] DONE "Cro"
     - Not used in ver<0.2.0+>.
  - [X] DONE "HTTP::Tiny"

- [X] DONE Models implementation

- [X] DONE Embeddings implementation

- [X] DONE Refactor the code, so each functionality (audio, completion, moderation, etc)
  has a separate file.

- [X] DONE Refactor HTTP(S) retrieval functions to be simpler and more "uniform."

- [X] DONE De-Cro the request code.

  - Given the problems of using "Cro::HTTP::Client" and the implementations with `curl` and 
    ["HTTP::Tiny"](https://gitlab.com/jjatria/http-tiny/-/blob/master/examples/cookbook.md),
    it seems it is better to make the implementation of "WWW::OpenAI" more lightweight.

- [X] DONE Implement finding of textual answers

- [X] DONE Factor out finding of textual answers into a separate package
  - So, other LLMs can be used.
  - See ["ML::FindTextualAnswer"](https://github.com/antononcube/Raku-ML-FindTextualAnswer).

- [X] DONE Implement vision (over images)

--------

## References

### Articles

[AA1] Anton Antonov,
["Connecting Mathematica and Raku"](https://rakuforprediction.wordpress.com/2021/12/30/connecting-mathematica-and-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[JL1] Jérôme Louradour,
["New in the Wolfram Language: FindTextualAnswer"](https://blog.wolfram.com/2018/02/15/new-in-the-wolfram-language-findtextualanswer),
(2018),
[blog.wolfram.com](https://blog.wolfram.com/).

[OAIb1] OpenAI team,
["New models and developer products announced at DevDay"](https://openai.com/blog/new-models-and-developer-products-announced-at-devday),
(2023),
[OpenAI/blog](https://openai.com/blog).

### Packages

[AAp1] Anton Antonov,
[Lingua::Translation::DeepL Raku package](https://github.com/antononcube/Raku-Lingua-Translation-DeepL),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Text::CodeProcessing](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[ML::FindTextualAnswer](https://github.com/antononcube/Raku-ML-FindTextualAnswer),
(2023),
[GitHub/antononcube](https://github.com/antononcube).


[OAI1] OpenAI Platform, [OpenAI platform](https://platform.openai.com/).

[OAI2] OpenAI Platform, [OpenAI documentation](https://platform.openai.com/docs).

[OAIp1] OpenAI,
[OpenAI Python Library](https://github.com/openai/openai-python),
(2020),
[GitHub/openai](https://github.com/openai/).