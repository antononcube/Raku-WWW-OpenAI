
----

## Update (2026-11-09)

```text
Suggest updates of this Raku package, "WWW::OpenAI", with the newest models.
Just outlines the updates you propose, do not implement anything.
```

### Answer

## Proposed update outline

OpenAI Docs currently lists `gpt-6-astra`, `gpt-6.1-sol`, `gpt-6.1-terra`, and `gpt-6-luna` as the main model choices. I would prioritize Sol as the package’s general-purpose default candidate, with Astra, Terra, and Luna available for different workloads. [OpenAI model catalog](https://developers.openai.com/api/docs/models).

1. **Make the new models usable.** Add the four IDs to the hardcoded registry in [Models.rakumod](/home/vscode/Raku-WWW-OpenAI/lib/WWW/OpenAI/Models.rakumod:17), then review endpoint compatibility rules. Those rules currently recognize GPT-4 and GPT-5 names but omit GPT-6.

2. **Build out Responses support before changing the default.** The current Responses path in [ChatCompletions.rakumod](/home/vscode/Raku-WWW-OpenAI/lib/WWW/OpenAI/ChatCompletions.rakumod:200) joins message content into one string and drops roles and tools. Give Responses its own request and result handling, including reasoning settings and multimodal input, so new-model calls retain their meaning. OpenAI’s GPT-6 guidance starts with the Responses API. [Using GPT-6](https://developers.openai.com/api/docs/guides/latest-model).

3. **Then revisit defaults and examples.** [GetDefaultModel](/home/vscode/Raku-WWW-OpenAI/lib/WWW/OpenAI/Models.rakumod:195) still selects `gpt-5`. Choose a new default only after the intended request path works; keep the environment override. Refresh the older examples in [README.md](/home/vscode/Raku-WWW-OpenAI/README.md:49).

4. **Update image and audio wrappers by model family.** Add the current `gpt-image-2.6-sunburst` and `gpt-image-2.6-flare` options, checking their parameters and output handling in [ImageGenerations.rakumod](/home/vscode/Raku-WWW-OpenAI/lib/WWW/OpenAI/ImageGenerations.rakumod:44). Replace the Whisper-only transcription validation in [Audio.rakumod](/home/vscode/Raku-WWW-OpenAI/lib/WWW/OpenAI/Audio.rakumod:112) with model-specific support for `gpt-transcribe`. [Image models](https://developers.openai.com/api/docs/models), [GPT Transcribe](https://developers.openai.com/api/docs/models/gpt-transcribe).

5. **Mark retired examples clearly.** The registry and README still contain many historical IDs. Keep historical examples where useful, but distinguish them from recommended models and document relevant shutdown dates, including `gpt-5`, `whisper-1`, and older image models. [OpenAI deprecations](https://developers.openai.com/api/docs/deprecations).

No files were changed.

### **Clarification**

```
Ok. Sounds good. Just to be clear: the models that going to be depreciated soon but can be still used would be accessible after the changes?
```

### Answer

Yes. Under the proposed changes, **deprecated models that OpenAI still serves would remain selectable by their model ID**. They would be marked as deprecated and would no longer be recommended as defaults.

Availability still depends on OpenAI and your account. Once OpenAI shuts a model down, keeping its name in the package cannot make it work. For example, OpenAI Docs lists `gpt-5` for shutdown on December 11, 2026, and `whisper-1` on February 26, 2027. [OpenAI deprecations](https://developers.openai.com/api/docs/deprecations).

I have not made any changes yet.
