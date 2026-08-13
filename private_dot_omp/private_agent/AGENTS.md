# Purpose

oh-my-pi (omp) agent configuration: model catalog (`models.yml`) and routing/failover (`config.yml`). The chezmoi source is the single source of truth; the runtime copy lives at `~/.omp/agent/` (managed by omp itself — it rewrites `config.yml` in place, so it drifts).

# Ownership

- Edit model catalog and routing intent ONLY here (chezmoi source), never in `~/.omp/agent/`.
- After changing `models.yml`, copy it to `~/.omp/agent/models.yml` (omp does not modify it).
- After changing routing in `config.yml`, patch the live `~/.omp/agent/config.yml` surgically — never overwrite it, it accumulates omp-managed keys (`webSearchOrder`, `retry`, etc.).

# Local Contracts

## Routing contract (as of 2026-08)

Priority order: **ollama-cloud → google → alibaba-token-plan → openrouter (free) → omniroute**.

- `default_model` and all `modelRoles` start on `ollama-cloud` (primary engine).
- Failover: each ollama-cloud model → `google/gemini-2.5-flash` → alibaba → `openrouter/openai/gpt-oss-20b:free` → `omniroute/free-forever` → `omniroute/auto/best-free`.
- Gemini is rate-limited on free tier: treat it as a pass-through, not a destination.
- Capability-preserving handoffs: `gemini-2.5-flash` → `alibaba-token-plan/qwen3.7-plus` (keeps vision); `gemini-2.5-pro` → `alibaba-token-plan/qwen3.7-max` (keeps deep reasoning).
- Vision chains use ollama-cloud multimodal models (`gemini-3-flash-preview`, `kimi-k2.7-code`); alibaba models are text-only except `qwen3.7-plus`.

## Built-in providers (no provider block needed in models.yml)

- `ollama-cloud` — OAuth via `/login ollama-cloud`.
- `alibaba-token-plan` — env `ALIBABA_TOKEN_PLAN_API_KEY` (or `BAILIAN_TOKEN_PLAN_API_KEY`); endpoint `token-plan.ap-southeast-1.maas.aliyuncs.com`.
- Custom providers that DO need blocks here: `omniroute` (local proxy, `OMNIROUTE_API_KEY`), `google` (`GEMINI_API_KEY`, `authHeader: false` — query-param auth), `openrouter` (`OPENROUTER_API_KEY`).

## Model entry conventions

Every model entry pins `contextWindow` and `compat` (supportsDeveloperRole, supportsToolChoice, maxTokensField, supportsUsageInStreaming). Use `max_output_tokens` for google, `max_tokens` for everything else.

# Work Guidance

- Verify provider/model availability with `omp models find <provider>` before referencing an id.
- Query `~/.omp/agent/models.db` (table `model_cache`, column `models` JSON) for authoritative context windows and capabilities.
- Model ids in `fallbackModel` and `modelRoles` must match entries in `models.yml` exactly (`provider/model`).

# Verification

```sh
python3 -c "import yaml; yaml.safe_load(open('models.yml')); yaml.safe_load(open('config.yml')); print('OK')"
omp models find ollama-cloud
```
