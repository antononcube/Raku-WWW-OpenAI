use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Test;

my $method = 'tiny';

plan *;

## 1
ok openai-create-image("racoon with perls in the style of Hannah Wilke", size => 'small', :$method);

done-testing;
