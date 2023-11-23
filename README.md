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
# Roger Rabbit is a fictional character from the 1988 film "Who Framed Roger Rabbit." He does not exist in real life.}]
```

Another one using Bulgarian:

```perl6
openai-playground('Колко групи могат да се намерят в този облак от точки.', max-tokens => 64);
```
```
# [{finish_reason => length, index => 0, logprobs => (Any), text => 
# 
# Трудно е да се каже точен брой на групите, тъй като това зависи от критериите, по които се определят групите. Могат да се}]
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
#     say $item;
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
# Sure! Here's an example of Raku code that demonstrates how to loop over a list:
# 
# ```raku
# my @list = <apple banana cherry>;
# for @list -> $item {
#     say $item;
# }
# ```
# 
# This code declares an array `@list` with three elements: `apple`, `banana`, and `cherry`. The `for` loop iterates over each item in `@list`, assigning it to the variable `$item`, and then prints the value of `$item`. The output would be:
# 
# ```
# apple
# banana
# cherry
# ```
# 
# You
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
# +--------------------------------+------------------------------+------------------------------+--------------------------------+
# | 2                              | 0                            | 3                            | 1                              |
# +--------------------------------+------------------------------+------------------------------+--------------------------------+
# | Min    => -0.6316688           | Min    => -0.5905979         | Min    => -0.60487235        | Min    => -0.6675609           |
# | 1st-Qu => -0.012534879         | 1st-Qu => -0.013208558       | 1st-Qu => -0.0129462655      | 1st-Qu => -0.0122597895        |
# | Mean   => -0.00072970771235612 | Mean   => -0.000762066322233 | Mean   => -0.000754160801387 | Mean   => -0.00076258629791471 |
# | Median => -0.00061200845       | Median => -0.0010125666      | Median => -0.00072666709     | Median => -0.000313577955      |
# | 3rd-Qu => 0.0118897265         | 3rd-Qu => 0.0123315665       | 3rd-Qu => 0.012172342        | 3rd-Qu => 0.0111436975         |
# | Max    => 0.21271802           | Max    => 0.2120242          | Max    => 0.22197673         | Max    => 0.22817883           |
# +--------------------------------+------------------------------+------------------------------+--------------------------------+
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
["gpt-4-vision-preview"](https://openai.com/blog/new-models-and-developer-products-announced-at-devday#OpenAI), [OAIb1].

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
# 1. The first image is a vibrant and colorful illustration featuring a raccoon perched on a tree branch, surrounded by a multitude of butterflies in various colors.
# 
# 2. The second image is another colorful illustration showcasing two raccoons in a whimsical landscape with trees, a clear sky, and an abundance of butterflies. A noticeable signpost with unreadable text and the date "2023.11" is affixed to a large tree.
# 
# 3. The third image depicts three raccoons sitting within a tree hollow, against the backdrop of a glowing, autumnal forest scene, again with numerous butterflies fluttering around them.
```

The function `encode-image` from the namespace `WWW::OpenAI::ChatCompletions` can be used
to get Base64 image strings corresponding to image files. For example:

```perl6, results=asis
my $img3 = WWW::OpenAI::ChatCompletions::encode-image($fname3);
'![](' ~ $img3 ~ ')';  
```
![](data:image/jpeg;base64,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)


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
# 🐍 Python 😠 sucks, 🦝 Raku 🤘 rocks, and 🐪 Perl 😒 is annoying.
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
# Titicaca is in the Andes on the border of Bolivia and Peru.
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
#   openai-playground [<words> ...] [--path=<Str>] [-n[=UInt]] [--mt|--max-tokens[=UInt]] [-m|--model=<Str>] [-r|--role=<Str>] [-t|--temperature[=Real]] [-l|--language=<Str>] [--response-format=<Str>] [-a|--auth-key=<Str>] [--timeout[=UInt]] [-f|--format=<Str>] [--method=<Str>] -- Command given as a sequence of words.
#   
#     --path=<Str>                Path, one of 'chat/completions', 'images/generations', 'images/edits', 'images/variations', 'moderations', 'audio/transcriptions', 'audio/translations', 'embeddings', or 'models'. [default: 'chat/completions']
#     -n[=UInt]                   Number of completions or generations. [default: 1]
#     --mt|--max-tokens[=UInt]    The maximum number of tokens to generate in the completion. [default: 100]
#     -m|--model=<Str>            Model. [default: 'Whatever']
#     -r|--role=<Str>             Role. [default: 'user']
#     -t|--temperature[=Real]     Temperature. [default: 0.7]
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