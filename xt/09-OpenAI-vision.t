use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Image::Markup::Utilities;
use Test;

my $method = 'tiny';
my $format = 'values';

plan *;

## 1
my $fname1 = $*CWD ~ '/resources/ThreeHunters.jpg';
my $img1 = Image::Markup::Utilities::image-encode($fname1);
isa-ok $img1, Str;

## 2
#say openai-completion("How many mammals?", images => $fname1, :$method, :$format, max-tokens => 900);
isa-ok openai-completion("How many mammals", images => $fname1, :$method, :$format), Str;

## 3
#say openai-playground('How many mammals?', images => $*CWD ~ '/resources/ThreeHunters.jpg/', max-tokens => 900, :$format);
isa-ok openai-playground('How many mammals?', images => $*CWD ~ '/resources/ThreeHunters.jpg/', max-tokens => 300, :$format), Str;

## 4
#note openai-playground('How many kind of mammal species on Earth?', max-tokens => 300, :$format), Str;
isa-ok openai-playground('How many kind of mammal species on Earth?', max-tokens => 300, :$format), Str;

## 5
isa-ok openai-playground('How many kind of mammal species on Earth?', images => [], max-tokens => 300, :$format), Str;

done-testing;
