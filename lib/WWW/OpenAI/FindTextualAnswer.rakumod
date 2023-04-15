use v6.d;

use WWW::OpenAI::ChatCompletions;
use WWW::OpenAI::Models;
use WWW::OpenAI::TextCompletions;

unit module WWW::OpenAI::FindTextualAnswer;


#============================================================
# Completions
#============================================================


#| OpenAI utilization for finding textual answers.
our proto OpenAIFindTextualAnswer(Str $text,
                                  $questions,
                                  :$sep = Whatever,
                                  :$model = Whatever,
                                  :$strip-with = Empty,
                                  :$prelude is copy = Whatever,
                                  :$request is copy = Whatever,
                                  Bool :p(:$pairs) = False,
                                  |) is export {*}

multi sub OpenAIFindTextualAnswer(Str $text,
                                  Str $question,
                                  :$sep = Whatever,
                                  :$model = Whatever,
                                  :$strip-with = Empty,
                                  :$prelude is copy = Whatever,
                                  :$request is copy = Whatever,
                                  Bool :p(:$pairs) = False,
                                  *%args) {
    return OpenAIFindTextualAnswer($text, [$question,], :$sep, :$model, :$strip-with, :$prelude, :$request, :$pairs, |%args);
}

#| OpenAI utilization for finding textual answers.
multi sub OpenAIFindTextualAnswer(Str $text is copy,
                                  @questions,
                                  :$sep is copy = Whatever,
                                  :$model is copy = Whatever,
                                  :$strip-with is copy = Empty,
                                  :$prelude is copy = Whatever,
                                  :$request is copy = Whatever,
                                  Bool :p(:$pairs) = False,
                                  *%args) {

    #------------------------------------------------------
    # Process separator
    #------------------------------------------------------

    if $sep.isa(Whatever) { $sep = ')'; }
    die "The argument \$sep is expected to be a string or Whatever" unless $sep ~~ Str;

    #------------------------------------------------------
    # Process model
    #------------------------------------------------------

    if $model.isa(Whatever) { $model = 'gpt-3.5-turbo'; }
    die "The argument \$model is expected to be Whatever or one of {openai-model-to-end-points.keys.join(', ')}."
    unless $model ∈ openai-model-to-end-points.keys;

    #------------------------------------------------------
    # Process prolog
    #------------------------------------------------------

    if $prelude.isa(Whatever) { $prelude = 'Given the text: '; }
    die "The argument \$prelude is expected to be a string or Whatever."
    unless $prelude ~~ Str;

    #------------------------------------------------------
    # Process request
    #------------------------------------------------------

    if $request.isa(Whatever) {
        my $s = @questions.elems == 1 ?? '' !! 's';
        $request = "{@questions.elems ==1 ?? 'give' !! 'list'} the shortest answer$s of the question$s:";
    }
    die "The argument \$request is expected to be a string or Whatever."
    unless $request ~~ Str;

    #------------------------------------------------------
    # Make query
    #------------------------------------------------------

    my Str $query = $prelude ~ ' "' ~ $text ~ '" ' ~ $request;

    if @questions == 1 {
        $query ~= "\n{@questions[0]}";
    } else {
        for (1 .. @questions.elems) -> $i {
            $query ~= "\n$i$sep {@questions[$i-1]}";
        }
    }

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    my &func = openai-is-chat-completion-model($model) ?? &OpenAIChatCompletion !! &OpenAITextCompletion;

    my $res = &func($query, :$model, format => 'values', |%args.grep({ $_.key ne 'format' }).Hash);

    #------------------------------------------------------
    # Process answers
    #------------------------------------------------------

    # Pick answers the are long enough.
    my @answers = $res.lines.grep({ $_.chars > @questions.elems.Str.chars + $sep.chars + 1 });

    if @answers.elems == @questions.elems {
        @answers = @answers.map({ $_.subst( / ^ \h* \d+ \h* $sep /, '' ).trim });
        if $strip-with.isa(WhateverCode) {
            for (^@questions.elems) -> $i {
                my $noWords = @questions[$i].split(/ <ws> | <punct> /, :skip-empty).unique.Array;
                @answers[$i] = @answers[$i].split(/ <ws> | <punct> /, :skip-empty).grep({ $_ ∉ $noWords }).join(' ');
                @answers[$i] =
                        @answers[$i]
                        .subst( / ^ The /, '' )
                        .subst( / ^ \h+ are \h+ /, '' )
                        .subst( / \h+ '.' $ /, '' )
                        .trim;
            }
        } elsif $strip-with ~~ Positional {
            my $noWords = $strip-with.grep(* ~~ Str).Array;
            for (^@questions.elems) -> $i {
                @answers[$i] = @answers[$i].split(/ <ws> | <punct> /, :skip-empty).grep({ $_.lc ∉ $noWords }).join(' ').trim;
            }
        } elsif $strip-with ~~ Callable {
            for (^@questions.elems) -> $i {
                @answers[$i] = $strip-with(@answers[$i]);
            }
        }

        if $pairs {
            return (@questions Z=> @answers).Array;
        }
        return @answers;
    }

    note 'The obtained answer does not have the expected form: a line with an answer for each question.';
    return $res;
}
