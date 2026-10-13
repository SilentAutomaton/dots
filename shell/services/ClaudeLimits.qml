pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs.services
import qs.modules.common

Singleton {
    id: root

    property bool loading: false
    property bool loaded: false
    property string error: ""
    property string lastRefresh: ""
    property var data: ({}) // { plan, rows: [{label, pct, resetStr}], credits }
    property real retryAt: 0

    function refresh() {
        if (Date.now() < root.retryAt) {
            root.error = `Rate limited, retry in ${Math.ceil((root.retryAt - Date.now()) / 60000)} min`;
            return;
        }
        root.loading = true;
        root.error = "";
        fetcher.running = false;
        fetcher.running = true;
    }

    function relTime(iso) {
        const t = new Date(iso).getTime();
        if (isNaN(t))
            return "";
        let m = Math.round((t - Date.now()) / 60000);
        if (m <= 0)
            return "resetting…";
        const d = Math.floor(m / 1440);
        m -= d * 1440;
        const h = Math.floor(m / 60);
        const mm = m % 60;
        if (d)
            return `resets in ${d}d ${h}h`;
        if (h)
            return `resets in ${h}h ${mm}m`;
        return `resets in ${mm}m`;
    }

    function limitRow(label, o) {
        if (!o || o.utilization === null || o.utilization === undefined)
            return null;
        return {
            "label": label,
            "pct": o.utilization,
            "resetStr": root.relTime(o.resets_at)
        };
    }

    function currencySymbol(code) {
        return ({
                "USD": "$",
                "EUR": "€",
                "GBP": "£"
            })[code] || (code + " ");
    }

    function windowName(kind) {
        const k = (kind || "").toLowerCase();
        if (k.includes("month"))
            return "monthly";
        if (k.includes("week") || k.includes("day"))
            return "weekly";
        if (k.includes("hour") || k.includes("session"))
            return "session";
        return kind;
    }

    // A model-scoped allowance (a weekly window only one model draws from) shows up
    // only in limits[]; the matching legacy buckets stay null.
    function scopedRows(d, rows) {
        const seen = new Set(rows.map(r => r.label));
        const out = [];
        for (const e of d.limits || []) {
            const model = e?.scope?.model;
            if (!model || typeof e.percent !== "number")
                continue;
            const window = root.windowName(e.kind);
            const name = model.display_name || model.id;
            const label = window === "weekly" ? `Weekly (${name})` : `${name} ${window}`;
            if (seen.has(label) || seen.has(`Weekly (${name.split(" ")[0]})`) && window === "weekly")
                continue;
            seen.add(label);
            out.push({
                "label": label,
                "pct": e.percent,
                "resetStr": root.relTime(e.resets_at)
            });
        }
        return out;
    }

    function refine(plan, d) {
        const rows = [root.limitRow("5-hour session", d.five_hour), root.limitRow("Weekly (all models)", d.seven_day), root.limitRow("Weekly (Opus)", d.seven_day_opus), root.limitRow("Weekly (Sonnet)", d.seven_day_sonnet)].filter(r => r !== null);
        rows.push(...root.scopedRows(d, rows));

        let credits = null;
        const sp = d.spend;
        if (sp && sp.enabled) {
            const div = Math.pow(10, sp.used?.exponent ?? 2);
            const used = (sp.used?.amount_minor ?? 0) / div;
            const limit = sp.limit ? sp.limit.amount_minor / div : null;
            credits = {
                "used": used,
                "limit": limit,
                "remaining": limit === null ? null : (limit - used),
                "pct": sp.percent ?? 0,
                "cur": root.currencySymbol(sp.used?.currency || d.extra_usage?.currency || "USD")
            };
        }

        return {
            "plan": plan,
            "rows": rows,
            "credits": credits
        };
    }

    // Off by default: each refresh is a request against the subscription API.
    Timer {
        interval: Config.options.sidebar.usage.refreshMinutes * 60000
        running: interval > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: fetcher
        command: ["bash", "-c", Quickshell.shellPath("scripts/claude-usage.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                if (text.trim().length === 0) {
                    root.error = "No response — is jq/curl available?";
                    return;
                }
                if (text.trim() === "EXPIRED") {
                    root.error = "Token expired — start claude to refresh it";
                    return;
                }
                try {
                    const lines = text.split("\n");
                    const plan = lines[0].trim();
                    const [code, retryAfter] = lines[lines.length - 1].trim().split(" ");
                    const body = lines.slice(1, -1).join("\n");
                    if (code === "429") {
                        root.retryAt = Date.now() + (parseInt(retryAfter) || 300) * 1000;
                        root.refresh();
                        return;
                    }
                    if (code !== "200") {
                        root.error = `HTTP ${code} — run \`claude\` to re-auth`;
                        return;
                    }
                    root.data = root.refine(plan, JSON.parse(body));
                    root.loaded = true;
                    root.lastRefresh = DateTime.time;
                } catch (e) {
                    root.error = e.message;
                }
            }
        }
    }
}
