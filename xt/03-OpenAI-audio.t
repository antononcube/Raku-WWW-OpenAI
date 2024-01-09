use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
my $fileName1 = $*CWD ~ '/resources/HelloRaccoonsEN.mp3';

ok openai-audio(
        $fileName1,
        type => 'transcriptions',
        format => "json",
        :$method);

## 2
my $fileName2 = $*CWD ~ '/resources/HowAreYouRU.mp3';

ok openai-audio(
        $fileName2,
        type => 'translations',
        format => "json",
        :$method);

## 3
my $fileName3 = $*TMPDIR ~ '/HowMuchIsTheFisth.mp3';

ok openai-audio(
        $fileName3,
        prompt => 'How much is the fish?',
        type => 'speech',
        format => "mp3",
        :$method);

done-testing;
