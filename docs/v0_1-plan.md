# v0.1 — Pipeline Sanity-Check Plan

**Goal:** Validate end-to-end (page serving → bot crawl → citation parsing → DB ingest → directional signal) at the smallest scope that proves the architecture before committing to the full v1 build.

**Authorized by Robert:** 2026-05-20.

## Scope vs. full study

| Dimension | v0.1 | v1 (full) |
|---|---|---|
| Page pairs | 20 (1 cluster) | 60 (4 clusters) |
| Topic cluster | GEO methodology only | All 4 |
| Prompt types | 1 (category-discovery) | 6 |
| Prompts per pair | 2 variants | 6 |
| Platforms | Perplexity API only | 6 |
| Repeated runs | 2 (spaced 3 days) | 3 |
| **Observations** | **160** | 6,480 |
| Adjudication | None (defer to v1) | 15% audit |

## Why Perplexity for v0.1

- Cleanest API: `response.citations[]` is an unambiguous array of cited URLs.
- Fastest indexing: ~24-48h from launch to first PerplexityBot crawl in past testing.
- Lowest per-query cost (~$0.025 on sonar-pro).
- If the pipeline can't parse Perplexity citations cleanly, it won't survive the harder platforms (ChatGPT Search and Google AI Mode have no public API and require Playwright + logged-in profiles).

## Why GEO-methodology cluster for v0.1

- Source content already exists at `geolocus.ai/methodology`.
- Claim parity is easiest to enforce when both versions paraphrase a single known source.
- Prompt-page entity match is clearest.

## Build phases (v0.1)

### Phase 1 — Infrastructure (~3 days)

- Subdomain `study.geolocus.ai` → Cloudflare Pages project + bot-router worker. Clone the `lavidge-bot-router` pattern (proven 6-layer bot detection, CF Cache API with version-bump invalidation, telemetry to a Supabase `bot_crawl_logs` table).
- Supabase schema: `page_pairs`, `prompt_runs`, `citations`, `bot_requests`. (Skip `page_audits` until v1 — pre-launch parity audit can run from JSON files for v0.1.)
- Bot logger middleware: UA-only verification for v0.1. (IP-range reverse-DNS verification is deferred to v1 because the v0.1 scale doesn't justify the engineering cost.)

### Phase 2 — Pages (~5 days)

- 20 matched pairs on GEO-methodology topics.
- URL structure: `/a/{pair_id}/` and `/b/{pair_id}/` with randomized control/treatment assignment via `hash(pair_id + STUDY_SEED) mod 2`.
- **Control** = production-style HTML, normal SEO tags, same substantive claims as treatment.
- **Treatment** = clean-room HTML with prerendered content, JSON-LD, primary-source anchors, fresh sitemap entry, `Last-Modified`, `/llms.txt`, `/llms-full.txt`, `/ai-content-index.json`.
- Pre-launch parity audit: same claims, same primary sources, same word-count band (treatment may reduce boilerplate but not add evidence).

### Phase 3 — Collector + pipeline (~3 days)

- Perplexity collector hitting `sonar-pro` with web search enabled. Trigger `LIVE LIVE LIVE` prompt prefix per existing memory to force fresh fetch.
- URL normalization library (lowercase host, strip tracking params, resolve redirects, normalize trailing slash, map canonical-equivalent).
- JSONL → Supabase ingest.
- Simple paired-rate comparison (no mixed-effects model yet — v0.1 is not powered for inference).

### Phase 4 — Run (~3 weeks calendar)

- 7-day indexing wait after launch (no prompts run during this window).
- 2 prompt runs spaced 3 days apart.
- 1-week analysis tail.

## Cost (v0.1)

| Item | Cost |
|---|---:|
| Perplexity API (160 obs × ~$0.025) | $4 |
| Perplexity Pro (parity UI cross-check) | $20 |
| Supabase | $0 (free tier sufficient at this scale) |
| CF Pages + DNS | $0 |
| Embeddings (position-adjusted word count) | <$1 |
| **Total cash** | **~$25** |

Engineering on Pro Max: ~10-15 working days of orchestrated dev. ~3-4 weeks elapsed including the 7-day indexing wait.

## Success gates (v0.1 → v1)

| Gate | Pass criterion |
|---|---|
| Pages crawlable | All 40 URLs return 200 + valid HTML + valid sitemap |
| Bots crawl treatment | >=3 of PerplexityBot / OAI-SearchBot / GPTBot / ClaudeBot / Bytespider / Google-Extended logged hitting treatment pages within 7 days of launch |
| Citation parser accuracy | Manual audit of 20 Perplexity responses → >=95% of cited URLs correctly extracted + normalized |
| Pipeline completion | >=150/160 observations land in Supabase (>=93%) |
| Directional signal | Treatment citation rate >= control by any margin. Not powered for inference; just confirms the test isn't dead in the water. |

## Decision at v0.1 end

- All 5 gates pass → scale to full 60-pair x 6-platform v1 study.
- Parsers pass, no signal → investigate content parity / indexing before scaling.
- Parsers fail or indexing fails → fix root cause; do NOT scale to v1.

## Key risks priced in for v0.1

1. **Content-parity confound.** If the 20 control pages end up subtly weaker than treatment (better headlines, more sources, better entity coverage on the treatment side), the study measures "we wrote better content," not the translation layer. Pre-launch claim-parity audit is the single highest-leverage QC step.
2. **Indexing delay not guaranteed.** PerplexityBot typically picks up new URLs in 24-48h, but a fresh subdomain with no inbound links could take longer. The 7-day wait window is conservative but not proof.
3. **Single-platform signal is fragile.** A null v0.1 result could be Perplexity-specific (e.g., PerplexityBot didn't crawl yet) rather than evidence against the translation-layer hypothesis. The decision tree above handles this — null result with parsers passing means investigate, not abandon.
