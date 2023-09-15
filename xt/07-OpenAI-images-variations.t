use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-variate-image($*CWD ~ '/resources/RandomMandala.png', size => 'small', :$method);

done-testing;
