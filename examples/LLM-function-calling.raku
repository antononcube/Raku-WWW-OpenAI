#!/usr/bin/env raku
use v6.d;

use WWW::OpenAI;
use LLM::Functions;
use JSON::Fast;

my $model = "gpt-5.1";
#my $model = "gpt-5.6-luna";

sub get-current-weather(Str $location, Str $unit = "fahrenheit") returns Str {
    return "It is currently sunny in $location with a temperature of 72 degrees $unit.";
}

my $function-spec = {
    type => "function",
    function => {
        name => "get-current-weather",
        description => "Get the current weather for a given location",
        parameters => {
            type => "object",
            properties => {
                'location' => {
                    type => "string",
                    description => "The city and state, e.g., San Francisco, CA"
                },
                'unit' => {
                    type => "string",
                    enum => ["celsius", "fahrenheit"],
                    description => "The temperature unit to use"
                }
            },
            required => ["location"]
        }
    }
};

my @messages =
    {role => "system", content =>  "You are a helpful assistant that can provide weather information."},
    {role => "user", content => "What's the weather in Boston, MA?"}
    ;

my @tools = [$function-spec,];

# Chat Completions function tools require no reasoning for gpt-5.6-luna.
# Use Responses instead if the workflow needs reasoning effort above 'none'.
my $response = openai-chat-completion(
    @messages,
    :@tools,
    :$model,
    reasoning-effort => 'none',
    max-tokens => 4096,
    format => "raku",
    temperature => 0.45
);

# Copy the message
my @messages2 = @messages;


say "response :", to-json($response[0]<message>);


my sub extract-tool-requests(%assistant-content) {
    my @requestObjects;
    if %assistant-content<tool_calls> {
        for |%assistant-content<tool_calls> -> %part {
            if %part<function> && %part<function><name> {
                my $name = %part<function><name>;
                my %args = from-json(%part<function><arguments> // '{}').Hash;
                @requestObjects.push( %part<id> => LLM::ToolRequest.new($name, %args) ) ;
            }
        }
    }
    return @requestObjects;
}


say extract-tool-requests($response[0]<message>);


my $assistant-message = $response[0]<message>;
if $assistant-message<tool_calls> {

    @messages2.push: {
        role => "assistant",
        tool_calls => $assistant-message<tool_calls>
    };

    my $tool-call = $assistant-message<tool_calls>[0];
    my $function-name = $tool-call<function><name>;
    my $function-args = from-json($tool-call<function><arguments>);
    
    if $function-name eq "get-current-weather" {
        my $result = get-current-weather(
            $function-args{'$location'} // $function-args<location>,
            $function-args{'$unit'} // $function-args<unit> // "fahrenheit"
        );
        @messages2.push: {
            role => "tool",
            content => $result,
            tool_call_id => $tool-call<id>
        };
        
        # Send the second request with function result
        my $final-response = openai-chat-completion(
            @messages2,
            :@tools,
            #tool_choice => "auto",
            :$model,
            reasoning-effort => 'none',
            format => "raku"
        );
        say "Assistant: $final-response[0]<message><content>";
    }
} else {
    say "Assistant: $assistant-message<content>";
}


say (:$assistant-message);


.say for @messages2;
