use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-edit-image($*CWD ~ '/resources/RandomMandala2.png', 'add cosmic background', size => 'small', :$method);

done-testing;
