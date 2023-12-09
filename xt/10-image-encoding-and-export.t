use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

## 1
isa-ok encode-image($*CWD ~ '/resources/RandomMandala.png'), Str;

## 2
my $img2 = encode-image($*CWD ~ '/resources/RandomMandala.png');
is export-image($*CWD ~ '/resources/RandomMandalaExported.png', $img2), True;

done-testing;
