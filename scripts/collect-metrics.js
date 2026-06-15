// scripts/collect-metrics.js
// Collects workflow metrics and pushes them to Supabase.
// Runs as a post-step in the opencode-pr-review GitHub Actions workflow.
// Zero-dependency: uses Node 20 native fetch() and built-in child_process.

import { execSync } from 'child_process';
import { readFileSync } from 'fs';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY;
const GITHUB_EVENT_PATH = process.env.GITHUB_EVENT_PATH;

const supabaseHeaders = {
  'Content-Type': 'application/json',
  'apikey': SUPABASE_KEY,
  'Authorization': `Bearer ${SUPABASE_KEY}`,
  'Prefer': 'return=representation',
};

async function supabasePost(table, body) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
    method: 'POST',
    headers: supabaseHeaders,
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Supabase POST ${table} failed [${res.status}]: ${err}`);
  }

  return res.json();
}

function execCommand(command) {
  try {
    return execSync(command, {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe'],
    }).trim();
  } catch (error) {
    console.warn(`⚠️  Command failed: ${command}`);
    console.warn(`    ${error.stderr || error.message}`);
    return null;
  }
}

function extractTokenCounts(obj) {
  if (!obj || typeof obj !== 'object') return null;

  const prompt =
    obj.promptTokens ??
    obj.prompt_tokens ??
    obj.inputTokens ??
    obj.input_tokens;

  const completion =
    obj.completionTokens ??
    obj.completion_tokens ??
    obj.outputTokens ??
    obj.output_tokens;

  const total = obj.totalTokens ?? obj.total_tokens;

  if (prompt === undefined && completion === undefined && total === undefined) {
    return null;
  }

  const p = Number(prompt) || 0;
  const c = Number(completion) || 0;
  const t = Number(total) || p + c;

  return { prompt_tokens: p, completion_tokens: c, total_tokens: t };
}

function findTokenUsage(data) {
  // 1. Top-level usage fields
  const topLevel = extractTokenCounts(data);
  if (topLevel) return topLevel;

  // 2. Inside info.tokens (may be a number, string, or object)
  if (data?.info) {
    if (typeof data.info.tokens === 'number' || typeof data.info.tokens === 'string') {
      const total = Number(data.info.tokens);
      if (!isNaN(total)) {
        return { prompt_tokens: 0, completion_tokens: 0, total_tokens: total };
      }
    }
    if (data.info.tokens && typeof data.info.tokens === 'object') {
      const infoTokens = extractTokenCounts(data.info.tokens);
      if (infoTokens) return infoTokens;
    }

    const infoTokens = extractTokenCounts(data.info);
    if (infoTokens) return infoTokens;
  }

  // 3. Inside explicit usage object
  if (data?.usage) {
    const usageTokens = extractTokenCounts(data.usage);
    if (usageTokens) return usageTokens;
  }

  // 4. Sum token counts from the messages array
  if (Array.isArray(data?.messages)) {
    let prompt = 0;
    let completion = 0;
    let total = 0;
    let found = false;

    for (const msg of data.messages) {
      const tokens = extractTokenCounts(msg);
      if (tokens) {
        found = true;
        prompt += tokens.prompt_tokens;
        completion += tokens.completion_tokens;
        total += tokens.total_tokens;
      } else if (typeof msg.tokens === 'number') {
        found = true;
        total += msg.tokens;
      }
    }

    if (found) {
      return {
        prompt_tokens: prompt,
        completion_tokens: completion,
        total_tokens: total || prompt + completion,
      };
    }
  }

  return null;
}

function extractTokenUsage() {
  try {
    // 1. Find the latest opencode session created by the review step.
    const sessionListOutput = execCommand(
      'opencode session list --format json --max-count 1'
    );
    if (!sessionListOutput) return null;

    const sessions = JSON.parse(sessionListOutput);
    const session = Array.isArray(sessions) ? sessions[0] : sessions;
    if (!session || !session.id) {
      console.warn('⚠️  No opencode session found');
      return null;
    }

    console.log(`🔍 Found opencode session: ${session.id}`);

    // 2. Export the full session JSON (contains token usage).
    const exportOutput = execCommand(`opencode export ${session.id}`);
    if (!exportOutput) return null;

    const sessionData = JSON.parse(exportOutput);
    const tokens = findTokenUsage(sessionData);

    if (!tokens) {
      console.warn('⚠️  Token usage not found in session export');
      console.warn('   Export keys:', Object.keys(sessionData || {}).join(', '));
      if (sessionData?.info) {
        console.warn('   Info keys:', Object.keys(sessionData.info).join(', '));
        console.warn('   info.tokens type:', typeof sessionData.info.tokens);
        if (sessionData.info.tokens && typeof sessionData.info.tokens === 'object') {
          console.warn('   info.tokens keys:', Object.keys(sessionData.info.tokens).join(', '));
        } else if (sessionData.info.tokens !== undefined) {
          console.warn('   info.tokens value:', sessionData.info.tokens);
        }
      }
      if (Array.isArray(sessionData?.messages) && sessionData.messages.length > 0) {
        console.warn('   First message keys:', Object.keys(sessionData.messages[0]).join(', '));
        if (sessionData.messages[0]?.info) {
          console.warn('   First message.info keys:', Object.keys(sessionData.messages[0].info).join(', '));
        }
      }
      return null;
    }

    return tokens;
  } catch (error) {
    console.warn(`⚠️  Token extraction failed: ${error.message}`);
    return null;
  }
}

async function main() {
  try {
    // 1. Read GitHub event context
    const event = JSON.parse(readFileSync(GITHUB_EVENT_PATH, 'utf8'));
    const pr = event.pull_request;
    if (!pr) {
      console.log('⚠️  Not a PR event, skipping metrics.');
      return;
    }

    // 2. Calculate job duration in seconds
    const startTime = parseInt(process.env.WORKFLOW_START_TIME || '0', 10);
    const durationSeconds = startTime
      ? Math.round(Date.now() / 1000 - startTime)
      : 0;

    // 3. Estimate runner cost and energy consumption
    const durationMinutes = durationSeconds / 60;
    const cost = durationMinutes * 0.008; // ubuntu-latest, public repo
    const energy = durationMinutes * 0.0003; // rough kWh estimate

    // 4. Insert run metrics
    const [run] = await supabasePost('review_runs', {
      repo_name: process.env.GITHUB_REPOSITORY,
      pr_number: pr.number,
      pr_title: pr.title,
      pr_author: pr.user?.login || 'unknown',
      github_run_id: parseInt(process.env.GITHUB_RUN_ID, 10),
      status: process.env.JOB_STATUS || 'completed',
      duration_seconds: durationSeconds,
      runner_os: 'ubuntu-latest',
      estimated_cost_usd: parseFloat(cost.toFixed(6)),
      estimated_energy_kwh: parseFloat(energy.toFixed(6)),
      commit_sha: process.env.GITHUB_SHA,
    });

    console.log(`✅ Metrics saved for PR #${pr.number} (run id: ${run.id})`);
    console.log(`   Duration: ${durationSeconds}s | Cost: $${cost.toFixed(4)} | Energy: ${energy.toFixed(6)} kWh`);

    // 5. Extract token usage from the opencode session created above.
    const tokens = extractTokenUsage();
    if (tokens) {
      const CONTEXT_WINDOW = 128000; // DeepSeek v4 context window
      await supabasePost('token_usage', {
        run_id: run.id,
        model: 'opencode/deepseek-v4-flash-free',
        prompt_tokens: tokens.prompt_tokens,
        completion_tokens: tokens.completion_tokens,
        total_tokens: tokens.total_tokens,
        estimated_remaining: Math.max(0, CONTEXT_WINDOW - tokens.total_tokens),
      });
      console.log(`   Tokens: ${tokens.total_tokens} total (${tokens.prompt_tokens} prompt + ${tokens.completion_tokens} completion)`);
    }
  } catch (error) {
    console.error('❌ Metrics collection failed:', error.message);
    // Do not fail the workflow because of a metrics error.
    process.exit(0);
  }
}

main();
