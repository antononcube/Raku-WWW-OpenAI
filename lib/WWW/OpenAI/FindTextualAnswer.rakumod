use v6.d;

use WWW::OpenAI::TextCompletions;

unit module WWW::OpenAI::FindTextualAnswer;


#============================================================
# Completions
#============================================================


#| OpenAI utilization for finding textual answers.
our proto OpenAIFindTextualAnswer(Str $text, $questions, :$sep = Whatever,  |) is export {*}

multi sub OpenAIFindTextualAnswer(Str $text, Str $question, :$sep = Whatever, *%args) {
    return OpenAIFindTextualAnswer($text, [$question,], :$sep, |%args);
}

#| OpenAI utilization for finding textual answers.
multi sub OpenAIFindTextualAnswer(Str $text is copy, @questions, :$sep is copy = Whatever, *%args) {

    #------------------------------------------------------
    # Process separator
    #------------------------------------------------------

    if $sep.isa(Whatever) { $sep = ')'; }
    die "The argument \$sep is expected to be a string or Whatever" unless $sep ~~ Str;

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

    my $res = OpenAITextCompletion($query, format => 'values', |%args.grep({ $_.key ne 'format' }).Hash);

    #------------------------------------------------------
    # Process answers
    #------------------------------------------------------

    note $res.lines.raku;
    my @answers = $res.lines.grep({ $_.chars > @questions.elems.Str.chars + $sep.chars + 1 });
    if @answers.elems == @questions.elems {
        return @answers.map({ $_.subst( / ^ \h* \d+ \h* $sep /, '' ).trim });
    } else {
        return $res;
    }
}
