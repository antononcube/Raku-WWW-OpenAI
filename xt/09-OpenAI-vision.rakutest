use v6.d;

use lib <. lib>;

use WWW::OpenAI;
use Image::Markup::Utilities;
use Test;

my $method = 'tiny';
my $format = 'values';
my $model = 'gpt-4-vision-preview';

plan *;

## 1
my $fname1 = $*CWD ~ '/resources/ThreeHunters.jpg';
my $img1 = Image::Markup::Utilities::image-encode($fname1);
isa-ok $img1, Str;

## 2
#say openai-completion("How many mammals?", images => $fname1, :$method, :$format, max-tokens => 900);
isa-ok openai-completion("How many mammals", images => $fname1, :$method, :$format), Str;

## 3
#say openai-playground('How many mammals?', images => $*CWD ~ '/resources/ThreeHunters.jpg/', max-tokens => 900, :$model, :$format);
isa-ok
        openai-playground('How many mammals?', images => $*CWD ~ '/resources/ThreeHunters.jpg/', max-tokens => 300, :$model, :$format),
        Str,
        'Specified model';

## 4
# note openai-playground('How many kind of mammal species on Earth?', max-tokens => 300, :$format), Str;
isa-ok openai-playground('How many kind of mammal species on Earth?', max-tokens => 300, :$format), Str;

done-testing;
