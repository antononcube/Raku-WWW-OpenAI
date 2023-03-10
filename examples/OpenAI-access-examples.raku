#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;
use Data::Reshapers;
use Data::Generators;

say openai-playground("how many rabits exist?", format => Whatever);