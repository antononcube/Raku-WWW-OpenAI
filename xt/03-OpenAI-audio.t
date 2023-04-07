use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

plan *;

## 1
my $fileName1 = $*CWD ~ '/resources/HelloRaccoonsEN.mp3';

ok openai-audio(
        $fileName1,
        type => 'transcriptions',
        format => "json",
        method => 'tiny');

## 2
my $fileName2 = $*CWD ~ '/resources/HowAreYouRU.mp3';

ok openai-audio(
        $fileName2,
        type => 'translations',
        format => "json",
        method => 'tiny');

done-testing;
