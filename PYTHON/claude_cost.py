import json, glob, os
from datetime import datetime, timezone, timedelta

LOCAL = timezone(timedelta(hours=-4))  # EDT

# per-MTok: input, output, cache_read, cache_write_5m, cache_write_1h
P = {
 "claude-opus-5":      (5,25,0.5,6.25,10),
 "claude-opus-4-8":    (5,25,0.5,6.25,10),
 "claude-opus-4-7":    (5,25,0.5,6.25,10),
 "claude-opus-4-6":    (5,25,0.5,6.25,10),
 "claude-opus-4-5":    (5,25,0.5,6.25,10),
 "claude-sonnet-5":    (2,10,0.2,2.5,4),
 "claude-sonnet-4-6":  (3,15,0.3,3.75,6),
 "claude-sonnet-4-5":  (2,10,0.2,2.5,4),
 "claude-haiku-4-5":   (1,5,0.1,1.25,2),
 "claude-fable-5-1":   (10,50,0.25,12.5,20),
 "claude-fable-5":     (10,50,1.0,12.5,20),
 # Specific version strings
 "claude-sonnet-4-5-20250929": (2,10,0.2,2.5,4),
 "claude-opus-4-5-20251101":   (5,25,0.5,6.25,10),
 "claude-haiku-4-5-20251001":  (1,5,0.1,1.25,2),
 "us.anthropic.claude-sonnet-4-5-20250929-v1:0": (2,10,0.2,2.5,4),
 "us.anthropic.claude-opus-4-5-20251101-v1:0":   (5,25,0.5,6.25,10),
 "us.anthropic.claude-haiku-4-5-20251001-v1:0":  (1,5,0.1,1.25,2),
}

def price(m):
    # Direct match
    if m in P: return P[m]
    # Substring match for any key
    for k,v in P.items():
        if k in m: return v
    return None

seen=set(); days={}; unknown=set()
root="/root/.claude/projects"
for f in glob.glob(os.path.join(root,"**","*.jsonl"), recursive=True):
    proj=os.path.basename(os.path.dirname(f))
    for line in open(f,encoding="utf-8",errors="replace"):
        try: r=json.loads(line)
        except: continue
        msg=r.get("message") or {}
        u=msg.get("usage")
        if not u: continue
        model=msg.get("model") or ""
        if model=="<synthetic>" or not model: continue
        key=(msg.get("id"), r.get("requestId"))
        if key[0] and key in seen: continue
        if key[0]: seen.add(key)
        ts=r.get("timestamp")
        if not ts: continue
        d=datetime.fromisoformat(ts.replace("Z","+00:00")).astimezone(LOCAL)
        day=d.strftime("%Y-%m-%d")
        pr=price(model)
        if pr is None:
            unknown.add(model); continue
        i=u.get("input_tokens",0) or 0
        o=u.get("output_tokens",0) or 0
        cr=u.get("cache_read_input_tokens",0) or 0
        cc=u.get("cache_creation") or {}
        c5=cc.get("ephemeral_5m_input_tokens",0) or 0
        c1=cc.get("ephemeral_1h_input_tokens",0) or 0
        if not (c5 or c1):
            c5=u.get("cache_creation_input_tokens",0) or 0
        cost=(i*pr[0]+o*pr[1]+cr*pr[2]+c5*pr[3]+c1*pr[4])/1e6
        e=days.setdefault(day,{"cost":0,"in":0,"out":0,"cr":0,"cw":0,"req":0,"models":{},"projects":{}})
        e["cost"]+=cost; e["in"]+=i; e["out"]+=o; e["cr"]+=cr; e["cw"]+=c5+c1; e["req"]+=1
        m=e["models"].setdefault(model,{"cost":0,"req":0,"out":0}); m["cost"]+=cost; m["req"]+=1; m["out"]+=o
        p=e["projects"].setdefault(proj,{"cost":0,"req":0}); p["cost"]+=cost; p["req"]+=1

# Calculate monthly totals
months = {}
for day in sorted(days):
    e = days[day]
    month = day[:7]  # YYYY-MM
    if month not in months:
        months[month] = {"cost": 0, "req": 0, "in": 0, "out": 0, "days": 0}
    months[month]["cost"] += e["cost"]
    months[month]["req"] += e["req"]
    months[month]["in"] += e["in"]
    months[month]["out"] += e["out"]
    months[month]["days"] += 1

# Print monthly summary
print("=" * 100)
print("MONTHLY SUMMARY")
print("=" * 100)
for month in sorted(months):
    m = months[month]
    avg_daily = m["cost"] / m["days"] if m["days"] > 0 else 0
    print(f"{month}  ${m['cost']:10.2f}  (${avg_daily:6.2f}/day avg)  {m['days']:2d} days  {m['req']:6d} reqs  in={m['in']:>12,}  out={m['out']:>11,}")
print()

# Print daily breakdown
print("=" * 100)
print("DAILY BREAKDOWN")
print("=" * 100)
for day in sorted(days):
    e=days[day]
    print(f"{day}  ${e['cost']:8.2f}  reqs={e['req']:5d}  in={e['in']:>10,}  out={e['out']:>9,}  cache_read={e['cr']:>12,}  cache_write={e['cw']:>10,}")
print()
if unknown: print("UNPRICED MODELS:", unknown)
