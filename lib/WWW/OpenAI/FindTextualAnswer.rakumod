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
                                  |) is export {*}

multi sub OpenAIFindTextualAnswer(Str $text,
                                  Str $question,
                                  :$sep = Whatever,
                                  :$model = Whatever,
                                  *%args) {
    return OpenAIFindTextualAnswer($text, [$question,], :$sep, :$model, |%args);
}

#| OpenAI utilization for finding textual answers.
multi sub OpenAIFindTextualAnswer(Str $text is copy,
                                  @questions,
                                  :$sep is copy = Whatever,
                                  :$model is copy = Whatever,
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
    die "The argument \$model is expected to be Whatever or one of"
    unless $model ∈ openai-model-to-end-points.keys;


    #------------------------------------------------------
    # Make query
    #------------------------------------------------------

    my Str $query = 'Given the text "' ~ $text ~ '" answer the ';

    if @questions == 1 {
        $query ~= "question:\n { @questions[0] }";
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

    my @answers = $res.lines.grep({ $_.chars > @questions.elems.Str.chars + $sep.chars + 1 });
    if @answers.elems == @questions.elems {
        return @answers.map({ $_.subst( / ^ \h* \d+ \h* $sep /, '' ).trim });
    } else {
        return $res;
    }
}
