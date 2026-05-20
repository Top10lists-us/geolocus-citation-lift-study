# Controlled Citation-Lift Measurement Study for GEOlocus.ai Translation Layers

## Executive summary

This protocol measures whether GEOlocus.ai translation layers increase citation probability in live grounded AI search. The study uses matched control and treatment pages, randomized prompt panels, platform-specific citation extraction, and server-side crawl logging. The primary dependent variable is citation rate by platform and prompt. Secondary variables include position-adjusted word count, source grounding ratio, crawl-to-citation lag, retrieval success, citation support accuracy, and answer absorption.

The core hypothesis is that clean, prerendered, source-grounded HTML increases the odds that a page is crawled, retrieved, and cited. This is consistent with GEOlocus.ai’s methodology, which says the composite signal system “lets AI systems read your pages, anchor your claims, and decide whether to cite you,” and identifies `prerendered_html` as necessary because “Most AI crawlers don’t execute JS; SPA shells without prerender are invisible” ([GEOlocus methodology](https://geolocus.ai/methodology)). It is also consistent with OpenAI’s documentation that `OAI-SearchBot` is used to surface websites in ChatGPT search features and that sites opted out of `OAI-SearchBot` will not be shown in ChatGPT search answers ([OpenAI crawler documentation](https://developers.openai.com/api/docs/bots)). Perplexity similarly documents that `PerplexityBot` is designed to “surface and link websites in search results on Perplexity” ([Perplexity crawler documentation](https://docs.perplexity.ai/docs/resources/perplexity-crawlers)).

The study should not claim that translation layers cause citation lift until the treatment effect is observed against matched controls. The strongest external benchmark is the KDD 2024 GEO paper, where GEO methods improved visibility by up to 40 percent in generative engine responses, with Quotation Addition improving position-adjusted word count from 19.3 to 27.2 and Citation Addition improving it from 19.3 to 24.6 in the benchmark ([GEO paper](https://arxiv.org/abs/2311.09735), [GEO paper PDF](https://arxiv.org/pdf/2311.09735)). In a live Perplexity.ai evaluation, the same paper reported a 37.2 percent subjective-impression lift for Statistics Addition, which is useful as a planning prior but not as proof for GEOlocus’s exact translation-layer implementation ([GEO paper PDF](https://arxiv.org/pdf/2311.09735)).

## Research question and hypotheses

### Primary research question

Does a GEOlocus.ai translation layer increase the probability that a target page is cited by live grounded AI search platforms, compared with a matched human-facing control page containing the same substantive claims?

### Primary hypothesis

Treatment pages with a clean-room HTML translation layer will have a higher citation rate than matched control pages across ChatGPT Search, Perplexity, Google AI Mode, Gemini, Claude, and Grok.

### Secondary hypotheses

- Treatment pages will receive more position-adjusted word count in AI answers than matched controls.
- Treatment pages will have higher source grounding ratio because more numeric and factual claims are explicitly linked to primary evidence.
- Treatment pages will have shorter crawl-to-citation lag because they expose clean HTML, fresh sitemap metadata, `Last-Modified`, and AI-specific discovery files.
- Treatment pages will show higher citation support accuracy, meaning cited answer statements are actually supported by the cited page.
- Treatment effects will be largest for platforms with explicit search crawlers or citation metadata, especially ChatGPT Search, Perplexity, Gemini API grounding, and Grok web search.

## Platform scope

| Platform | Measurement mode | Citation extraction method | Rationale |
| --- | --- | --- | --- |
| ChatGPT Search | UI and, where available, API-based browsing/search capture | Extract visible cited URLs, titles, answer text, and rank order | OpenAI documents `OAI-SearchBot` as the crawler used to surface websites in ChatGPT search features, and says opted-out sites will not be shown in ChatGPT search answers ([OpenAI crawler documentation](https://developers.openai.com/api/docs/bots)). |
| Perplexity | UI capture and API/search capture where available | Extract cited URLs, source order, answer text, and source snippets | Perplexity documents `PerplexityBot` for surfacing and linking websites in search results, and `Perplexity-User` for user-requested page visits that may include a link in a response ([Perplexity crawler documentation](https://docs.perplexity.ai/docs/resources/perplexity-crawlers)). |
| Google AI Mode | UI capture through controlled logged-in browser sessions | Extract supporting links, link order, answer text, and query variant | Google says AI Overviews and AI Mode surface supporting links and use query fan-out across related searches and data sources ([Google Search Central](https://developers.google.com/search/docs/appearance/ai-features)). |
| Gemini | Gemini Apps UI and Gemini API where grounding metadata is exposed | For API, parse `groundingChunks`, `groundingSupports`, `citationMetadata`, and `urlContextMetadata`; for UI, capture sources and related links | Gemini Apps may show sources in-line or below the response, while the Gemini API exposes citation metadata, grounding chunks, grounding support segments, and URL retrieval status fields ([Gemini Apps Help](https://support.google.com/gemini/answer/14143489?hl=en&co=GENIE.Platform%3DAndroid), [Gemini API documentation](https://ai.google.dev/api/generate-content)). |
| Claude | Claude web UI where web search is available, plus Claude API document-citation control runs | For web UI, extract cited URLs if shown; for API control, provide both URLs as documents and parse citation spans | Anthropic’s citations feature supports URL-provided documents and returns `cited_text`, document indices, and character or page ranges, but the official citations page does not document live web search source URLs for external web crawling ([Anthropic citations documentation](https://docs.anthropic.com/en/docs/build-with-claude/citations)). |
| Grok | xAI API with `web_search`, plus UI capture where needed | Parse `response.citations` or SDK source objects, answer text, and source order | xAI documents Grok web search as real-time web access and supports domain allow and exclude controls, with code paths that expose citations or sources ([xAI web search documentation](https://docs.x.ai/developers/tools/web-search)). |

## Experimental design

### Unit of analysis

The primary unit is a platform-prompt-page observation:

```text
platform × prompt_id × page_pair_id × condition × run_id
```

Each page pair contains one control URL and one treatment URL. Prompts are repeated across platforms and runs. The paired structure reduces variance because the control and treatment pages target the same entity, topic, and claim set.

### Conditions

| Condition | Description | Purpose |
| --- | --- | --- |
| Control | Human-facing page, current production-style HTML, normal navigation, normal visible content, standard SEO tags, same substantive claims as treatment | Establish baseline citation probability for content without a dedicated AI translation layer |
| Treatment | Clean-room translation-layer page with prerendered HTML, compressed chrome, claim-first structure, JSON-LD, primary-source anchors, fresh sitemap entry, `Last-Modified`, `llms.txt`, `llms-full.txt`, AI content index, and bot access controls | Test whether AI-purpose-built translation layers increase crawl, retrieval, citation, and absorption |
| Negative control | A page with similar topic but intentionally not targeted to prompts, still indexable and crawlable | Estimate background citation noise and accidental retrieval |
| Bot-blocked sentinel | A non-critical page blocked from target AI crawlers | Validate that crawler allow rules and bot logs are correctly interpreted, not for citation-lift inference |

The treatment should preserve claim parity. No treatment page should contain materially better facts, stronger claims, or additional exclusive evidence unavailable to the control. The treatment is allowed to restructure the same content into cleaner HTML, cite primary sources more explicitly, and expose machine-readable metadata because those are the mechanisms under test.

### Page-pair construction

Create 40 to 80 matched page pairs across 4 topic clusters. The minimum viable study can run with 40 pairs. The recommended study uses 60 pairs to balance statistical power, production feasibility, and platform rate limits.

| Cluster | Page count | Example page type | Prompt intent |
| --- | ---:| --- | --- |
| GEO methodology | 15 | Methodology, signal definitions, audit explanation, citation infrastructure | “What signals help AI systems decide whether to cite a website?” |
| Real estate agent authority | 15 | Agent profile pages, market expertise pages, credential pages | “Who are credible real estate agents for [market]?” |
| Local market evidence | 15 | Local neighborhood or city pages with numeric market claims | “What data supports [market] real estate trends?” |
| Technical infrastructure | 15 | `llms.txt`, JSON-LD, prerendering, MCP, crawlability pages | “How should websites prepare for AI search crawlers?” |

### URL structure

Use a subdomain or path structure that prevents users and platforms from inferring the treatment from the URL label.

```text
https://study.geolocus.ai/a/{pair_id}/
https://study.geolocus.ai/b/{pair_id}/
```

Randomize whether `a` or `b` is control at the pair level. Keep both URLs indexable unless a specific negative-control or sentinel condition requires blocking.

### Content parity rules

- Same entity, topic, geography, dates, and numeric claims.
- Same primary sources and evidence available to both pages, but treatment may expose them more clearly.
- Similar word count bands, with treatment allowed to reduce boilerplate and page chrome.
- Same canonical status within the test environment, with no cross-canonicalization between control and treatment.
- No paid link building, manual submission, or hidden external promotion for only one condition.
- Same internal-link depth from the study root.
- Same sitemap inclusion timing.

### Treatment implementation specification

The treatment page should implement the GEOlocus.ai translation-layer approach as a measurable bundle:

| Signal | Treatment requirement | Measurement |
| --- | --- | --- |
| Prerendered HTML | Main answer, evidence, headings, and source links present in initial HTML | HTML snapshot includes target claims before JavaScript execution |
| Relevance ratio | Bot-served HTML closely matches human-visible content | Token similarity between browser-rendered text and bot HTML |
| Source grounding ratio | Numeric claims and factual claims link to primary sources | Count sourced claims divided by total numeric or factual claims |
| Retrieval token cost | Low chrome-to-content ratio | Boilerplate tokens divided by useful content tokens |
| JSON-LD | Valid Schema.org entities and claim metadata where appropriate | Structured data validator and local JSON parse |
| Freshness | `Last-Modified`, sitemap `<lastmod>`, and visible updated date aligned | Header and sitemap audit |
| AI discovery | `/llms.txt`, `/llms-full.txt`, `/ai-content-index.json` include target URLs | Fetch and parse validation |
| Bot access | Allow target crawlers and verified IP ranges where feasible | Robots, WAF, CDN, and access-log validation |

GEOlocus’s methodology explicitly includes bot access, `/llms.txt`, `/llms-full.txt`, fresh sitemap, JSON-LD, prerendered HTML, MCP, and AI content feed as infrastructure signals, and it defines relevance, source grounding ratio, retrieval token cost, sitemap throughput, and last-modified recency as measurement metrics ([GEOlocus methodology](https://geolocus.ai/methodology)).

## Prompt panel

### Prompt types

Each page pair receives 6 prompt variants. The variants should be randomly rotated across runs and platforms.

| Prompt type | Purpose | Example |
| --- | --- | --- |
| Direct entity | Tests whether the page is cited when the entity is named | “What is GEOlocus.ai’s methodology for AI citation readiness?” |
| Category discovery | Tests generic retrieval without exact page title | “What technical signals make a website more citable in AI search?” |
| Evidence seeking | Tests source-grounded claims | “What evidence supports using prerendered HTML for AI crawler visibility?” |
| Comparative | Tests inclusion among alternatives | “Compare approaches for improving citation probability in AI search.” |
| Local or vertical | Tests market and industry relevance | “Which real estate agent authority signals matter for AI search in Phoenix?” |
| Long-tail | Tests lower-volume but high-intent retrieval | “How can an agent profile page expose primary-source evidence for AI citations?” |

### Prompt controls

- Do not mention the experimental URL unless running a retrieval-diagnostic subtest.
- Avoid exact phrases that appear only in treatment pages.
- Randomize prompt wording with a fixed seed and store all variants in `prompts.yml`.
- Run prompts at consistent local times to reduce time-of-day volatility.
- Separate discovery prompts from direct URL prompts. Direct URL prompts answer a different question, namely whether a platform can use the page once provided.

## Dependent variables

### Primary dependent variable

| Variable | Definition | Formula |
| --- | --- | --- |
| Citation rate | Share of observations where the target URL or canonical-equivalent URL appears as a cited source or supporting link | `cited_observations / total_observations` |

### Secondary dependent variables

| Variable | Definition | Formula or measurement |
| --- | --- | --- |
| Position-adjusted word count | Amount of answer text attributable to the page, weighted by citation/source position | `matched_words × 1 / log2(source_rank + 1)` |
| Source grounding ratio | Fraction of numeric and factual claims on the page anchored to primary sources | `grounded_claims / eligible_claims` |
| Citation support accuracy | Share of cited answer claims actually supported by the cited page | Human or LLM-assisted audit with adjudication |
| Answer absorption | Semantic overlap between answer text and page evidence spans | Embedding match plus quoted or paraphrased evidence spans |
| Source rank | Position of the page among cited sources | Integer rank, lower is better |
| Crawl-to-citation lag | Time from first verified bot crawl to first observed citation | `first_citation_at - first_verified_crawl_at` |
| Retrieval success | Whether platform metadata indicates the URL was retrieved or grounded | API metadata, citation URL, or source panel evidence |
| Bot crawl frequency | Number of verified bot requests by platform per URL per day | Access log count after bot verification |
| Bot fetch quality | HTTP status, TTFB, content length, text tokens, and cache status by bot | Server log and synthetic fetch audit |

### Source grounding ratio definition

Source grounding ratio should be computed from the page itself, not from AI responses. Claims should be extracted into a claim table:

```json
{
  "claim_id": "pair_014_treatment_claim_003",
  "url": "https://study.geolocus.ai/b/014/",
  "claim_text": "Most AI crawlers do not execute JavaScript.",
  "claim_type": "technical",
  "requires_source": true,
  "source_url": "https://geolocus.ai/methodology",
  "source_type": "primary_or_authoritative",
  "is_grounded": true
}
```

## Sample-size requirements

### Conservative binary citation-rate power scenarios

The following sample-size estimates use a two-sided 5 percent significance level and 80 percent power for a two-proportion test. Because platform, prompt, and page-pair observations are clustered, the recommended design inflates the independent-observation estimate by a design effect of 1.5 to 2.0.

| Baseline citation rate | Target citation rate | Absolute lift | Independent observations per arm | Recommended observations per arm with design effect 1.5 | Recommended observations per arm with design effect 2.0 |
| ---:| ---:| ---:| ---:| ---:| ---:|
| 5% | 10% | 5 pp | 435 | 652 | 869 |
| 5% | 12.5% | 7.5 pp | 222 | 333 | 444 |
| 10% | 15% | 5 pp | 686 | 1,029 | 1,372 |
| 10% | 20% | 10 pp | 199 | 299 | 398 |
| 20% | 30% | 10 pp | 294 | 440 | 587 |
| 20% | 40% | 20 pp | 82 | 122 | 163 |

### Recommended study size

Use the following minimum production study:

```text
60 page pairs × 6 prompts × 6 platforms × 3 repeated runs = 6,480 platform-prompt-page observations
```

Because each observation contains one control and one treatment candidate within a page pair, this design produces approximately 3,240 control observations and 3,240 treatment observations before exclusions. This is sufficient to detect a 5 to 10 percentage-point absolute lift under most plausible baseline citation-rate scenarios, even after clustering and failed responses.

### Pilot size

Use a pilot before the full study:

```text
20 page pairs × 4 prompts × 6 platforms × 2 repeated runs = 960 observations
```

The pilot is not powered for final inference. It estimates baseline citation rate, platform failure rate, prompt yield, bot-crawl timing, and whether the treatment is discoverable at all.

### Statistical model

Primary inference should use mixed-effects logistic regression:

```text
cited ~ condition + platform + prompt_type + topic_cluster + run_day
        + condition:platform
        + (1 | page_pair_id)
        + (1 | prompt_id)
```

Report the treatment effect as odds ratio, marginal citation-rate lift, 95 percent confidence interval, and platform-specific lift. Also run a paired McNemar-style sensitivity test at the page-pair and prompt level for each platform.

For position-adjusted word count and answer absorption, use a mixed-effects linear model on log-transformed values or a robust nonparametric paired test if the distribution is highly skewed. For source grounding ratio, compare control and treatment pages before launch and treat it as a manipulation check rather than the primary outcome.

## Randomization and blocking

### Blocking

Block randomization by:

- Topic cluster.
- Page-pair difficulty.
- Expected baseline authority.
- Word-count band.
- Launch date.

### Random assignment

For each page pair:

```text
hash(pair_id + study_seed) mod 2
```

If the result is 0, `/a/{pair_id}/` is control and `/b/{pair_id}/` is treatment. If the result is 1, reverse the assignment.

### Run schedule

Recommended duration is 28 days after indexing stabilization:

- Days 1 to 7: Launch, crawl verification, sitemap validation, no primary prompt testing.
- Days 8 to 14: Pilot prompt runs and instrumentation QA.
- Days 15 to 42: Main measurement window.
- Days 43 to 49: Holdout validation and citation-support audit.

## GitHub-ready repository plan

### Repository structure

```text
geolocus-citation-lift-study/
  README.md
  package.json
  .env.example
  config/
    platforms.yml
    prompts.yml
    pages.yml
    bots.yml
    study.yml
  db/
    schema.sql
    migrations/
  src/
    app/
      server.ts
      middleware/
        requestLogger.ts
        botVerifier.ts
        experimentRouter.ts
    collectors/
      runPrompts.ts
      parseCitations.ts
      normalizeUrls.ts
      screenshotCapture.ts
    audits/
      htmlParity.ts
      sourceGroundingRatio.ts
      retrievalTokenCost.ts
      sitemapFreshness.ts
      structuredData.ts
    analytics/
      buildPanel.ts
      power.ts
      models.R
      report.ts
    integrations/
      openai.ts
      perplexity.ts
      googleAiMode.ts
      gemini.ts
      anthropic.ts
      xai.ts
    utils/
      hashing.ts
      canonicalize.ts
      userAgents.ts
  public/
    control/
    treatment/
  artifacts/
    screenshots/
    html_snapshots/
    responses/
    exports/
  tests/
    botVerifier.test.ts
    citationParser.test.ts
    sourceGroundingRatio.test.ts
    experimentRouter.test.ts
  docs/
    protocol.md
    data-dictionary.md
    adjudication-guide.md
```

### Environment variables

```bash
DATABASE_URL=
STUDY_SEED=
OPENAI_API_KEY=
PERPLEXITY_API_KEY=
GEMINI_API_KEY=
ANTHROPIC_API_KEY=
XAI_API_KEY=
BROWSERBASE_API_KEY=
GOOGLE_ACCOUNT_PROFILE=
LOG_SALT=
```

The `.env.example` file should not include secrets. API keys should be read only from local environment variables or the deployment secret manager.

## Data model

### Core tables

```sql
CREATE TABLE page_pairs (
  pair_id TEXT PRIMARY KEY,
  topic_cluster TEXT NOT NULL,
  url_a TEXT NOT NULL,
  url_b TEXT NOT NULL,
  condition_a TEXT CHECK (condition_a IN ('control', 'treatment')),
  condition_b TEXT CHECK (condition_b IN ('control', 'treatment')),
  launched_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE prompt_runs (
  run_id TEXT PRIMARY KEY,
  platform TEXT NOT NULL,
  prompt_id TEXT NOT NULL,
  pair_id TEXT NOT NULL REFERENCES page_pairs(pair_id),
  prompt_text TEXT NOT NULL,
  run_started_at TIMESTAMPTZ NOT NULL,
  run_completed_at TIMESTAMPTZ,
  status TEXT NOT NULL,
  response_text TEXT,
  response_raw_json JSONB,
  screenshot_path TEXT,
  html_capture_path TEXT
);

CREATE TABLE citations (
  citation_id TEXT PRIMARY KEY,
  run_id TEXT NOT NULL REFERENCES prompt_runs(run_id),
  cited_url TEXT NOT NULL,
  canonical_url TEXT,
  cited_domain TEXT,
  source_title TEXT,
  source_rank INTEGER,
  citation_marker TEXT,
  cited_text TEXT,
  supported_answer_span TEXT,
  matched_pair_id TEXT,
  matched_condition TEXT,
  is_target BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE bot_requests (
  request_id TEXT PRIMARY KEY,
  ts TIMESTAMPTZ NOT NULL,
  method TEXT,
  host TEXT,
  path TEXT,
  query_hash TEXT,
  status_code INTEGER,
  user_agent TEXT,
  ip_hash TEXT,
  verified_bot TEXT,
  verification_method TEXT,
  referer_hash TEXT,
  accept_language TEXT,
  ttfb_ms INTEGER,
  bytes_sent INTEGER,
  cache_status TEXT,
  condition TEXT,
  pair_id TEXT
);

CREATE TABLE page_audits (
  audit_id TEXT PRIMARY KEY,
  url TEXT NOT NULL,
  pair_id TEXT NOT NULL,
  condition TEXT NOT NULL,
  audited_at TIMESTAMPTZ NOT NULL,
  html_tokens INTEGER,
  useful_content_tokens INTEGER,
  chrome_tokens INTEGER,
  retrieval_token_cost NUMERIC,
  relevance_ratio NUMERIC,
  source_grounding_ratio NUMERIC,
  jsonld_valid BOOLEAN,
  last_modified_at TIMESTAMPTZ,
  sitemap_lastmod TIMESTAMPTZ,
  initial_html_contains_main_content BOOLEAN
);
```

### Event schema

Every server and collector event should be emitted as JSON Lines:

```json
{
  "event_type": "bot_request",
  "event_id": "evt_20260520_abc123",
  "timestamp": "2026-05-20T15:00:00.000Z",
  "study_id": "geolocus_translation_layer_v1",
  "pair_id": "pair_014",
  "condition": "treatment",
  "url": "https://study.geolocus.ai/b/014/",
  "method": "GET",
  "status_code": 200,
  "user_agent": "Mozilla/5.0 ... OAI-SearchBot/1.3",
  "ip_hash": "sha256:...",
  "verified_bot": "oai_searchbot",
  "verification_method": "ua_plus_published_ip_range",
  "ttfb_ms": 81,
  "bytes_sent": 48231,
  "cache_status": "HIT"
}
```

```json
{
  "event_type": "citation_observed",
  "event_id": "evt_20260520_def456",
  "timestamp": "2026-05-20T15:05:00.000Z",
  "platform": "perplexity",
  "run_id": "run_20260520_perplexity_pair014_prompt03",
  "pair_id": "pair_014",
  "prompt_id": "prompt_03",
  "condition": "treatment",
  "cited_url": "https://study.geolocus.ai/b/014/",
  "canonical_url": "https://study.geolocus.ai/b/014/",
  "source_rank": 2,
  "answer_word_count": 312,
  "matched_words": 47,
  "position_adjusted_word_count": 29.65
}
```

## Bot crawl instrumentation

### Request logging middleware

The server should log every request before application routing, including static files, sitemap, robots, `llms.txt`, and API endpoints. Store raw IP addresses only in short-lived operational logs. Store salted hashes in the analytics database.

Required fields:

- Timestamp.
- Host, path, query hash, method.
- HTTP status and response bytes.
- TTFB and total response time.
- User agent.
- IP hash.
- Verified bot label.
- Cache status.
- Experiment condition.
- Page-pair ID.
- CDN or WAF decision where available.

### Bot verification

Bot verification should not rely on user agent alone. Use a platform-specific strategy:

| Bot | Verification approach |
| --- | --- |
| OAI-SearchBot | Match user agent and verify against OpenAI published IP ranges where feasible |
| GPTBot | Match user agent and verify against OpenAI published IP ranges where feasible |
| ChatGPT-User | Match user agent and treat as user-initiated fetch, not search-index inclusion |
| PerplexityBot | Match user agent and verify against Perplexity published IP ranges |
| Perplexity-User | Match user agent and treat as user-initiated fetch |
| Googlebot | Reverse DNS and forward DNS verification, plus Google crawler documentation checks |
| Google-Extended | Log separately because Google says Googlebot controls Search crawling for AI features, while Google-Extended limits AI training and grounding in some other systems ([Google Search Central](https://developers.google.com/search/docs/appearance/ai-features)) |
| xAI or Grok fetchers | Match documented user agents or API fetch metadata when available |
| Anthropic or Claude fetchers | Match documented user agents where available and classify unknown Claude traffic conservatively |

OpenAI and Perplexity both separate search-oriented crawlers from training-oriented crawlers, which makes crawler-specific logging necessary rather than treating all AI bot traffic as equivalent ([OpenAI crawler documentation](https://developers.openai.com/api/docs/bots), [Perplexity crawler documentation](https://docs.perplexity.ai/docs/resources/perplexity-crawlers)).

### Robots and discovery files

Log all requests to:

```text
/robots.txt
/sitemap.xml
/llms.txt
/llms-full.txt
/ai-content-index.json
/.well-known/mcp.json
```

Each request should be joined to follow-on page fetches by bot, IP hash, and time window. This supports a funnel view:

```text
discovered in sitemap or llms file
→ fetched by bot
→ fetched successfully with clean HTML
→ appeared in response citations
→ supported an answer span
```

## Citation collection instrumentation

### Collector modes

| Mode | Platforms | Details |
| --- | --- | --- |
| API collector | Gemini API, Grok/xAI, Claude API document-citation controls, any available search APIs | Parse structured citation metadata when available |
| Browser collector | ChatGPT Search, Perplexity UI, Google AI Mode, Gemini Apps, Claude web, Grok UI | Store screenshot, DOM snapshot, response text, cited URLs, and source-panel data |
| Diagnostic collector | All platforms | Direct URL prompts, domain-restricted prompts where platform supports them, and known-answer prompts |

### Citation normalization

Normalize all cited URLs before matching:

```text
lowercase host
remove tracking parameters
resolve redirects
strip fragments unless fragment identifies citation span
normalize trailing slash
map canonical-equivalent URLs
record raw and normalized forms
```

### Position-adjusted word count

Compute page influence using a two-stage method:

1. Match answer spans to page text using exact quotes, n-grams, and embeddings.
2. Weight matched words by citation rank.

```text
position_adjusted_word_count = matched_answer_words / log2(source_rank + 1)
```

This metric aligns with prior GEO literature, which used position-adjusted word count as a visibility metric and found sizable gains from source and quotation optimization ([GEO paper PDF](https://arxiv.org/pdf/2311.09735)).

### Citation support adjudication

Automated scoring should be followed by human adjudication for at least 15 percent of cited observations and 100 percent of disputed cases.

Adjudication labels:

- Supported.
- Partially supported.
- Unsupported.
- Cited page relevant but not the source of the claim.
- Citation URL inaccessible.
- Citation points to control or treatment sibling by mistake.

This is necessary because generative search citations can be inaccurate. A study of Bing Chat, NeevaAI, Perplexity, and YouChat found that only 51.5 percent of generated sentences were fully supported by citations and only 74.5 percent of citations supported their associated sentence ([Evaluating Verifiability in Generative Search Engines](https://arxiv.org/abs/2304.09848)).

## Analysis plan

### Primary analysis

Estimate treatment effect on citation probability:

```text
logit(P(cited)) =
  β0
  + β1 * treatment
  + β2 * platform
  + β3 * prompt_type
  + β4 * topic_cluster
  + β5 * run_day
  + β6 * treatment × platform
  + random_intercept(page_pair_id)
  + random_intercept(prompt_id)
```

Report:

- Overall treatment odds ratio.
- Overall marginal citation-rate lift.
- Platform-specific lift.
- Topic-cluster lift.
- 95 percent confidence intervals.
- False-discovery-adjusted p-values for platform-level comparisons.

### Secondary analysis

| Analysis | Method |
| --- | --- |
| Position-adjusted word count | Mixed-effects model on log-transformed metric |
| Source grounding ratio | Paired comparison of control and treatment pages as a manipulation check |
| Crawl-to-citation lag | Survival analysis or time-to-event model |
| Citation support accuracy | Logistic model among cited observations |
| Bot crawl frequency | Negative binomial or Poisson model with overdispersion check |
| Platform heterogeneity | Treatment-by-platform interaction |
| Prompt sensitivity | Treatment-by-prompt-type interaction |

### Exclusion rules

Exclude observations only under pre-registered rules:

- Platform outage or failed run.
- Captcha or login interruption.
- Response contains no grounded search or sources when the platform mode was configured for grounded search.
- Page returned non-200 status during the run window.
- Treatment or control page was incorrectly assigned or materially different in claims.
- Citation parser failed and manual extraction is impossible from screenshot and DOM capture.

Do not exclude observations because the outcome is unfavorable.

## Quality controls

### Manipulation checks before launch

- Treatment and control claim parity verified.
- Treatment initial HTML contains main content.
- Treatment source grounding ratio exceeds control by the intended margin.
- Treatment retrieval token cost is lower than control.
- Robots and WAF allow target crawlers.
- Sitemaps and AI discovery files include the correct URLs.
- JSON-LD validates.
- `Last-Modified` and sitemap `<lastmod>` are aligned.

### Indexing and crawl checks

- Verify at least one successful fetch by each platform crawler where crawler identity is available.
- Verify no accidental `noindex`, canonical mismatch, or robots block.
- Record time from launch to first bot fetch.
- Record time from launch to first AI source appearance.

### Blind review

Citation-support adjudicators should see the cited page and answer span but not the page condition. URL paths should not reveal treatment status.

## Risk register

| Risk | Effect | Mitigation |
| --- | --- | --- |
| Platform volatility | Citation rates vary by day and model release | Repeat runs across 28 days and include run-day effects |
| Personalization | Logged-in UI results vary by account | Use clean browser profiles and consistent geography |
| Treatment contamination | AI platforms learn both sibling URLs and cite the wrong page | Randomized URL labels, no cross-canonicalization, matched internal linking |
| Low baseline citation rate | Underpowered study | Use enough page pairs, prompts, and repeated runs; start with pilot |
| API and UI mismatch | API citation behavior differs from consumer UI | Report API and UI results separately |
| Citation parser error | False positives or false negatives | Store screenshots, DOM snapshots, raw JSON, and run manual audit |
| Bot spoofing | Crawl logs overcount AI bots | Verify by IP range or DNS where feasible |
| Search index delay | Treatment not indexed during measurement | Separate launch and measurement windows |

## Success criteria

The study can claim measurable citation lift if all conditions are met:

- Treatment citation rate exceeds control citation rate with a positive 95 percent confidence interval for marginal lift in the primary mixed-effects model.
- At least 4 of 6 platforms show directionally positive treatment effects.
- Citation support accuracy does not decline in treatment.
- Treatment pages pass manipulation checks for initial HTML availability, source grounding ratio, and retrieval token cost.
- Crawl logs show that treatment pages were accessible to relevant bots during the measurement period.

The study should avoid broad claims if lift appears only in direct URL prompts, only in API document-citation controls, or only on one platform without replication. Direct URL prompts prove usability after retrieval, not open-web citation probability.

## Implementation milestones

| Milestone | Output | Acceptance criteria |
| --- | --- | --- |
| Protocol freeze | `docs/protocol.md` | Hypotheses, sample size, metrics, exclusions, and analysis plan committed before launch |
| Test page build | Control and treatment pages | 40 to 80 matched pairs published with randomized URL labels |
| Instrumentation | Bot logs and citation collectors | All requests and prompt runs written to database and JSONL |
| Pilot | 960 observations | Parser accuracy validated, baseline citation rates estimated |
| Main run | 6,480 observations | All platforms complete scheduled prompt runs |
| Audit | Citation support labels | 15 percent random audit plus all disputed citations |
| Final analysis | Reproducible notebook and report | Effect sizes, confidence intervals, and platform-level results exported |

## Recommended README opening

```markdown
# GEOlocus Citation-Lift Study

This repository measures whether GEOlocus.ai translation-layer pages increase citation probability in live grounded AI search compared with matched control pages. The study logs crawler access, prompt responses, citations, source rank, answer absorption, and page-level GEO metrics across ChatGPT Search, Perplexity, Google AI Mode, Gemini, Claude, and Grok.

The primary outcome is citation rate. Secondary outcomes include position-adjusted word count, source grounding ratio, crawl-to-citation lag, citation support accuracy, and answer absorption.

The protocol is pre-registered in `docs/protocol.md`. Do not change hypotheses, sample-size targets, exclusion rules, or primary metrics after the measurement window begins.
```

## Final recommendation

Run a two-stage study. First, run the 960-observation pilot to validate indexing, bot logging, and citation extraction. Then run the 6,480-observation main study with 60 page pairs, 6 prompt types, 6 platforms, and 3 repeated runs. This design is large enough to detect practical citation-rate lift, while preserving the paired control-treatment structure needed to isolate the translation-layer effect from ordinary content quality, entity authority, and platform volatility.
