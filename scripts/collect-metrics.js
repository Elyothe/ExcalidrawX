// scripts/collect-metrics.js
// Collects workflow metrics and pushes them to Supabase.
// Runs as a post-step in the opencode-pr-review GitHub Actions workflow.
// Zero-dependency: uses Node 20 native fetch().

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

async function main() {
  try {
    // 1. Read GitHub event context
    const event = JSON.parse(require('fs').readFileSync(GITHUB_EVENT_PATH, 'utf8'));
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

    // 5. Token usage — placeholder until we instrument openCode output.
    // Possible strategies:
    //   a) Pipe openCode stdout to a file and parse token counts.
    //   b) Use a --verbose flag if openCode exposes one.
    //   c) Call the underlying API directly to capture usage.* fields.
    console.log('⚠️  Token capture not yet implemented — see DASHBOARD.md §11.1');
  } catch (error) {
    console.error('❌ Metrics collection failed:', error.message);
    // Do not fail the workflow because of a metrics error.
    process.exit(0);
  }
}

main();
