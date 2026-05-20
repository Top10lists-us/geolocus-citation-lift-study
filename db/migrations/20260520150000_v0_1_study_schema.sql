-- GEOlocus Citation-Lift Study — v0.1 schema
-- Hosted in geoai Supabase (ref: gnizgbgclvzhhxrrozwv) under the study_ prefix.
-- Authorized: Robert 2026-05-20.
-- See docs/protocol.md "Core tables" section for the source spec.
-- page_audits is deferred to v1; pre-launch parity for v0.1 runs from JSON files.

-- ── page_pairs ────────────────────────────────────────────────────────────
create table if not exists public.study_page_pairs (
  pair_id        text primary key,
  topic_cluster  text not null,
  url_a          text not null,
  url_b          text not null,
  condition_a    text not null check (condition_a in ('control', 'treatment')),
  condition_b    text not null check (condition_b in ('control', 'treatment')),
  launched_at    timestamptz not null,
  study_id       text not null default 'geolocus_translation_layer_v0_1',
  created_at     timestamptz not null default now()
);

create index if not exists idx_study_page_pairs_cluster
  on public.study_page_pairs (topic_cluster);
create index if not exists idx_study_page_pairs_study_id
  on public.study_page_pairs (study_id);

-- ── prompt_runs ───────────────────────────────────────────────────────────
create table if not exists public.study_prompt_runs (
  run_id              text primary key,
  platform            text not null,
  prompt_id           text not null,
  pair_id             text not null references public.study_page_pairs(pair_id),
  prompt_text         text not null,
  run_started_at      timestamptz not null,
  run_completed_at    timestamptz,
  status              text not null,
  response_text       text,
  response_raw_json   jsonb,
  screenshot_path     text,
  html_capture_path   text,
  study_id            text not null default 'geolocus_translation_layer_v0_1'
);

create index if not exists idx_study_prompt_runs_pair_platform
  on public.study_prompt_runs (pair_id, platform);
create index if not exists idx_study_prompt_runs_status
  on public.study_prompt_runs (status);

-- ── citations ─────────────────────────────────────────────────────────────
create table if not exists public.study_citations (
  citation_id            text primary key,
  run_id                 text not null references public.study_prompt_runs(run_id),
  cited_url              text not null,
  canonical_url          text,
  cited_domain           text,
  source_title           text,
  source_rank            integer,
  citation_marker        text,
  cited_text             text,
  supported_answer_span  text,
  matched_pair_id        text,
  matched_condition      text,
  is_target              boolean not null default false,
  created_at             timestamptz not null default now()
);

create index if not exists idx_study_citations_run on public.study_citations (run_id);
create index if not exists idx_study_citations_target
  on public.study_citations (is_target) where is_target = true;
create index if not exists idx_study_citations_matched_pair
  on public.study_citations (matched_pair_id);

-- ── bot_requests (UA-only verification for v0.1) ──────────────────────────
create table if not exists public.study_bot_requests (
  request_id           text primary key,
  ts                   timestamptz not null default now(),
  method               text,
  host                 text,
  path                 text,
  query_hash           text,
  status_code          integer,
  user_agent           text,
  ip_hash              text,
  verified_bot         text,
  verification_method  text default 'ua_only',
  referer_hash         text,
  accept_language      text,
  ttfb_ms              integer,
  bytes_sent           integer,
  cache_status         text,
  condition            text,
  pair_id              text
);

create index if not exists idx_study_bot_requests_ts on public.study_bot_requests (ts desc);
create index if not exists idx_study_bot_requests_bot
  on public.study_bot_requests (verified_bot, ts desc);
create index if not exists idx_study_bot_requests_pair
  on public.study_bot_requests (pair_id, ts desc);

-- ── RLS — service-role-only on all 4 ──────────────────────────────────────
alter table public.study_page_pairs    enable row level security;
alter table public.study_prompt_runs   enable row level security;
alter table public.study_citations     enable row level security;
alter table public.study_bot_requests  enable row level security;

-- No policies = service-role-only access. Anon + authenticated roles cannot read or write.

comment on table public.study_page_pairs is
  'GEOlocus Citation-Lift Study v0.1 — matched control/treatment page pairs. See docs/protocol.md.';
comment on table public.study_prompt_runs is
  'GEOlocus Citation-Lift Study v0.1 — one row per platform-prompt-pair-run observation.';
comment on table public.study_citations is
  'GEOlocus Citation-Lift Study v0.1 — citations extracted from prompt_runs.response_raw_json.';
comment on table public.study_bot_requests is
  'GEOlocus Citation-Lift Study v0.1 — bot crawl telemetry from study.geolocus.ai CF Worker.';
