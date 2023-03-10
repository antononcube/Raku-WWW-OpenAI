#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use WWW::OpenAI;

say openai-playground("What is the population of Bulgaria?", format => Whatever);