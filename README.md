# GEOlocus Citation-Lift Study

This repository measures whether GEOlocus.ai translation-layer pages increase citation probability in live grounded AI search compared with matched control pages. The study logs crawler access, prompt responses, citations, source rank, answer absorption, and page-level GEO metrics across ChatGPT Search, Perplexity, Google AI Mode, Gemini, Claude, and Grok.

The primary outcome is citation rate. Secondary outcomes include position-adjusted word count, source grounding ratio, crawl-to-citation lag, citation support accuracy, and answer absorption.

The protocol is pre-registered in `docs/protocol.md`. Do not change hypotheses, sample-size targets, exclusion rules, or primary metrics after the measurement window begins.

## Phasing

**v0.1 (current) — pipeline sanity-check.** 20 page pairs in the GEO-methodology cluster, single-prompt-type, Perplexity API only, 160 observations. Validates that pages are crawlable, bots actually retrieve treatment URLs, citation parsing is accurate, and the pipeline writes clean observations to the database. Not powered for inference.

**v1 — full study.** 60 page pairs across 4 topic clusters, 6 prompt types, 6 platforms, 3 repeated runs = 6,480 observations. Powered to detect a 5-10 percentage-point lift at 5% baseline citation rate.

See `docs/protocol.md` for the full pre-registered protocol and `docs/v0_1-plan.md` for the v0.1 success gates that determine whether v1 launches.

## Directory layout

```
config/         platforms.yml, prompts.yml, pages.yml, bots.yml, study.yml
db/             schema.sql, migrations/
src/app/        server + bot-logging middleware + experimentRouter
src/collectors/ per-platform prompt-run collectors
src/audits/     pre-launch page audits (HTML parity, grounding ratio, etc.)
src/analytics/  panel build, power calc, mixed-effects model, report
src/integrations/  per-platform API clients
public/control/    control HTML pages (served at /a/{pair_id}/)
public/treatment/  treatment HTML pages (served at /b/{pair_id}/)
artifacts/      screenshots, html_snapshots, raw responses, exports
tests/          unit + integration tests
docs/           protocol, data dictionary, adjudication guide, v0.1 plan
```

## Status

Bootstrapped 2026-05-20. v0.1 epic + child issues filed in `.beads/`. Run `bd ready` for the current task list.
