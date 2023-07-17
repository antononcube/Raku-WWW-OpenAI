# Chat completion examples

## Introduction

This document demonstrates the usage of 
[engineered prompts](https://www.freecodecamp.org/news/how-to-communicate-with-ai-tools-prompt-engineering/) 
with ChatGPT (OpenAI) via the Raku package 
["WWW::OpenAI"](https://raku.land/zef:antononcube/WWW::OpenAI).

Here the package is loaded:

```perl6
use WWW::OpenAI;
```

----

## Chat completions with engineered prompts

Engineered (pre-)prompts chat completions can be specified using Pair objects.
The engineered prompt has to be associated with the role "system".
(OpenAI API documentation chapter/section ["Create chat completion"](https://platform.openai.com/docs/api-reference/chat/create) for details.)

### Emojify

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

Here is an example of chat completion with emojification:

```perl6
openai-chat-completion([ system => $preEmojify, user => 'Python sucks, Raku rocks, and Perl is annoying'], max-tokens => 200, format => 'values')
```

### Limerick styled

Here is a prompt for "limerick styling" (see the
[Wolfram Prompt Repository](https://resources.wolframcloud.com/PromptRepository/)
entry
["LimerickStyled"](https://resources.wolframcloud.com/PromptRepository/resources/LimerickStyled/)).

```perl6
my $preLimerick = q:to/END/;
Respond in the form of a limerick.
You must always observe the correct rhyme scheme for a limerick
END
```

Here is an example limerick rephrasing of descriptions of Raku modules:

```perl6
my @descriptions = [
    "Raku SDK for Resend",
    "A module that allows true inline use of Brainfuck code",
    "ML::FindTextualAnswer provides function(s) for finding sub-strings in given text that appear to answer given questions.",
];

for @descriptions -> $d {
    say '=' x 80;
    say $d;
    say '-' x 80;
    say openai-chat-completion([system => $preLimerick, $d], max-tokens => 200, format => 'values')
}
```


### Headline suggester

Here is a prompt for "headline suggestion" (see the
[Wolfram Prompt Repository](https://resources.wolframcloud.com/PromptRepository/)
entry
["HeadlineSuggest"](https://resources.wolframcloud.com/PromptRepository/resources/HeadlineSuggest/)).

```perl6
my $preHeadline = q:to/END/;
The following text needs a headline. Make suggestions appropriate for a mainstream newspaper or journal. 
Generate no more than 2 headline(s).  
DO NOT number the list. Put each headline on a new line. Headlines should not be numbered, and should not be enclosed in quotation marks.

The text that requires a headline is: 
END
```

Here is an part of the post 
["2023.29 DSLs and ASTs"](https://rakudoweekly.blog/2023/07/17/2023-29-dsls-and-asts/) 
from the blog
["Rakudo Weekly News"](https://rakudoweekly.blog):

```perl6
my $blogPost = q:to/END/;
Matthew Stuckwisch gave two very interesting presentations at the 2023 Perl and Raku Conference in Toronto:

Towards Slangs and DSLs (and GPLs)
Brainfucking with RakuAST (/r/rakulang comments)
Highly recommended if you’re interested in using the new RakuAST capabilities in your code.

Bruce Gray also gave two, more basic presentations about Raku:

Sorting *Whatever in $LANG
Raku for Beginners
Wenzel’s Corner
Wenzel P.P. Peppmeyer has been worried about the continued availability of issues and their discussions on Github, and decided to make it possible to archive them.

Anton’s Corner
Anton Antonov attempts to reveal the secret of Generating documents via templates and LLMs.

Joe’s Corner
Joe Brenner wants the world to know that the informal Raku Study Group is coming together on Zoom every two weeks.

Steve’s Corner
Steve Roe follows up on their blog post about sigils in an essay about the differences in approach between procedural, functional and object oriented programming in the Raku Programming Language.

Raku Steering Council
The minutes of the meeting of 15 July have been published.

Weeklies
Weekly Challenge #226 is available for your perusal.
END

$blogPost.words.elems
```

Here is an example of chat completion of headline suggestions:

```perl6
openai-chat-completion([ system => $preHeadline, $blogPost], max-tokens => 200, format => 'values')
```

Here is another (more playful) example:

```perl6
my $preHeadline2 = $preHeadline.subst(
'Make suggestions appropriate for a mainstream newspaper or journal.',
'Make humorous suggestions appropriate for a geeky audience.'
); 

openai-chat-completion([ system => $preHeadline2, $blogPost], temperature => 1.1, max-tokens => 200, format => 'values')
```

