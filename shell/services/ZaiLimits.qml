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

    readonly property var unitNames: ({ 2: "minute", 3: "hour", 4: "day", 5: "month", 6: "week" })

    function refresh() {
        root.loading = true;
        root.error = "";
        fetcher.running = false;
        fetcher.running = true;
    }

    function relTime(when) {
        const t = typeof when === "number" ? when : new Date(when).getTime();
        if (isNaN(t)) return "";
        let m = Math.round((t - Date.now()) / 60000);
        if (m <= 0) return "resetting…";
        const d = Math.floor(m / 1440);
        m -= d * 1440;
        const h = Math.floor(m / 60);
        const mm = m % 60;
        if (d) return `resets in ${d}d ${h}h`;
        if (h) return `resets in ${h}h ${mm}m`;
        return `resets in ${mm}m`;
    }

    function num(v) {
        return Math.round(v * 100) / 100;
    }

    // Windows are identified by unit+number, never by position: a plan without a weekly
    // window simply omits that entry, and a pay-as-you-go key has no windows at all.
    function windowLabel(e) {
        const unit = root.unitNames[e.unit];
        const n = e.number || 1;
        if (!unit) return "Quota";
        if (unit === "hour") return n === 5 ? "5-hour session" : `${n}-hour window`;
        if (unit === "week") return n === 1 ? "Weekly" : `${n} weeks`;
        if (unit === "month") return n === 1 ? "Monthly" : `${n} months`;
        if (unit === "day") return n === 1 ? "Daily" : `${n} days`;
        return `${n} ${unit}s`;
    }

    function percentOf(e) {
        if (typeof e.percentage === "number") return e.percentage;
        if (typeof e.currentValue === "number" && typeof e.usage === "number" && e.usage > 0)
            return e.currentValue / e.usage * 100;
        return null;
    }

    function subText(e) {
        const parts = [];
        if (typeof e.currentValue === "number" && typeof e.usage === "number")
            parts.push(`${root.num(e.currentValue)} of ${root.num(e.usage)}`);
        else if (typeof e.remaining === "number")
            parts.push(`${root.num(e.remaining)} left`);
        const reset = e.nextResetTime ? root.relTime(e.nextResetTime) : "";
        if (reset) parts.push(reset);
        return parts.join(" · ");
    }

    function refine(body) {
        const d = body && body.data ? body.data : (body || {});
        const limits = d.limits || body.limits || [];
        const rows = [];
        for (const e of limits) {
            if (!e) continue;
            const pct = root.percentOf(e);
            if (pct === null) continue;
            rows.push({ "label": root.windowLabel(e), "pct": pct, "resetStr": root.subText(e) });
        }
        return { "plan": d.level || "", "rows": rows };
    }

    function balance(body) {
        const d = body?.success ? body.data : null;
        if (!d || typeof d.availableBalance !== "number")
            return null;
        const limit = (d.rechargeAmount || 0) + (d.giveAmount || 0);
        return {
            "label": "API balance",
            "used": d.totalSpendAmount || 0,
            "limit": limit,
            "remaining": d.availableBalance,
            "pct": limit > 0 ? (d.totalSpendAmount || 0) / limit * 100 : 0,
            "cur": "$"
        };
    }

    function block(text) {
        const lines = text.trim().split("\n");
        return { "code": lines[lines.length - 1].trim(), "body": lines.slice(0, -1).join("\n") };
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
        // The key goes to curl through a pipe, so it never shows up in the process list.
        command: ["bash", "-c", "C=\"$HOME/.config/zai/key.json\" && "
            + "H=$(jq -e -r '.apiKey // empty | \"Authorization: \" + .' \"$C\" 2>/dev/null) || { printf 'NOKEY\\n'; exit 0; } && "
            + "get() { printf '%s\\n' \"$H\" | curl -s -w '\\n%{http_code}' -H @- -H 'Accept-Language: en-US,en' \"https://api.z.ai/api/$1\"; } && "
            + "get monitor/usage/quota/limit && printf '\\n---\\n' && get biz/account/query-customer-account-report"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                const raw = text.trim();
                if (raw.length === 0) { root.error = "No response — is jq/curl available?"; return; }
                if (raw === "NOKEY") { root.error = "No key — put it in ~/.config/zai/key.json"; return; }
                try {
                    const [quota, bal] = text.split("\n---\n").map(root.block);
                    if (quota.code !== "200") { root.error = `HTTP ${quota.code} — check the z.ai key`; return; }
                    const parsed = root.refine(JSON.parse(quota.body));
                    parsed.credits = bal && bal.code === "200" ? root.balance(JSON.parse(bal.body)) : null;
                    if (parsed.rows.length === 0 && !parsed.credits) { root.error = "No subscription windows on this key"; return; }
                    root.data = parsed;
                    root.loaded = true;
                    root.lastRefresh = DateTime.time;
                } catch (e) { root.error = e.message; }
            }
        }
    }
}
