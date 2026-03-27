Here's the full technical breakdown of the HydroAlert dashboard:

---

## 1. Visual Hierarchy & Layout

**Grid System:**
- **Header**: Full-width `border-b` strip — logo left, status badges + admin profile right
- **KPI Row**: `grid-cols-4 gap-3` — four equal summary cards
- **Telemetry Cards**: `grid-cols-3 gap-4` — one per ESP32 node
- **Bottom Section**: `grid-cols-2 gap-4` — Incidents (left) + Shelters (right)
- **System Logs**: Full-width terminal-style list
- **Container**: `max-w-[1600px] mx-auto`, `p-6 space-y-6`

**Information Density Logic:**
District sensor cards are larger because they contain **5 data layers** (header/badge, large water level + trend, 3 threshold bars, connectivity footer) — they're the primary decision-making surface. Incident/Shelter panels use compact list rows since they're **action queues**, not monitoring surfaces.

---

## 2. Design System & Styling

### Color Palette (HSL → Hex)

| Token | HSL | Hex | Usage |
|---|---|---|---|
| `--status-normal` | `142 72% 45%` | **#1FBA4F** | Safe / Online |
| `--status-alert` | `38 92% 55%` | **#F0A422** | Watch / Pending |
| `--status-critical` | `0 80% 55%` | **#E23636** | Warning / Critical |
| `--background` | `220 20% 7%` | **#0F1218** | Page background |
| `--card` | `220 18% 10%` | **#151A22** | Card surfaces |
| `--border` | `220 14% 18%` | **#272D38** | Borders |
| `--muted` | `220 14% 14%` | **#1E232C** | Muted backgrounds |
| `--muted-foreground` | `215 12% 50%` | **#718096** | Secondary text |
| `--primary` | `142 72% 45%` | **#1FBA4F** | Brand green accent |

**Glow effects** use `box-shadow` with status color at 40-50% opacity (e.g., `0 0 12px hsl(142 72% 45% / 0.4)`).

The "glassmorphism" is actually **layered opacity** — status badge backgrounds use `bg-status-{level}/15` (15% opacity fill) with matching text color, not blur-based glass.

### Typography

| Element | Font | Weight | Size |
|---|---|---|---|
| Brand title | Inter (sans) | 700 (bold) | `text-xl` |
| Data readouts (water level) | System mono | 700 | `text-4xl` |
| Sensor IDs, timestamps | JetBrains Mono | 400-600 | `text-[10px]` / `text-xs` |
| Section labels | Mono | 600 | `text-xs uppercase tracking-widest` |
| Body text | Inter | 400-500 | `text-xs` / `text-sm` |

**Weight scaling**: Primary data (`4.8m`) is `font-mono text-4xl font-bold`. Labels are `text-[10px] font-mono uppercase`. This creates a ~4:1 size ratio between actionable data and metadata.

### Segmented Progress Bars

These are **not** segmented — they're **three independent bars**, one per threshold:

```
NORMAL  ████████████████░░░░  3.5m
ALERT   ███████████████████░  4.5m
CRITICAL ██████████████████████ 6.0m
```

Each bar: `h-1 rounded-full bg-muted` (track) with a fill div using `bg-status-{key}` and `width: (waterLevel / thresholdValue) * 100%`, capped at 100%. When a value exceeds the threshold, that bar fills completely — visually communicating **which thresholds have been breached**.

---

## 3. UX & Functional Logic

### System Alert Level Logic

```typescript
const highestAlert = sensorNodes.reduce((max, n) => {
  const order = { normal: 0, alert: 1, critical: 2 };
  return order[n.alertLevel] > order[max.alertLevel] ? n : max;
}, sensorNodes[0]);
```

**Worst-case escalation**: The global alert takes the **maximum severity** across all nodes. One critical node (South at 6.3m) → entire system shows **WARNING**. This is intentional — a single breach demands system-wide attention.

### Incident Report Lifecycle

1. **Submitted** → status: `pending` (amber badge, validate/reject buttons visible)
2. **Admin validates** → status: `validated` (green badge, logged as `INFO: "Incident report IR-xxxx validated by admin"`)
3. **Admin rejects** → status: `rejected` (red badge, logged as `WARNING: "Incident report IR-xxxx rejected — unverified claim"`)

Reports include: reporter name, district, description, timestamp, photo indicator, severity level (low/medium/high).

### System Logs Categorization

| Tag | Display | Color | Purpose |
|---|---|---|---|
| `info` | `INFO` | Green | Automated events (notifications sent, reports validated) |
| `warning` | `WARNING` | Amber | Alert triggers, rejected reports |
| `override` | `OVRD` | Amber | Manual admin actions (threshold changes, status toggles) |
| `error` | `ERROR` | Red | System failures (not currently triggered) |

Each log entry tracks: `timestamp`, `action` (description), `actor` (SYSTEM or admin name), `type`.

---

## 4. Asset Identification

**Icon Library**: **Lucide React** (`lucide-react@0.462.0`)

| Icon | Component | Usage |
|---|---|---|
| `Shield` | Brand logo | Header identity |
| `Activity` | Weather alert | Active disturbance badge |
| `Wifi` / `WifiOff` | Connectivity | Sensor online/offline status |
| `Battery` | Power | Node battery percentage |
| `ArrowUp` / `ArrowDown` / `Minus` | Trend | Water level direction |
| `AlertTriangle` | Alerts | System alert level, warnings |
| `Radio` | Sensors | Active sensor count |
| `FileCheck` | Reports | Incident report count |
| `Users` | Occupancy | Shelter occupancy |
| `Terminal` | Logs | System logs header |
| `Settings` | Override | Manual override log entries |
| `Info` | Information | Info-level log entries |
| `MapPin` | Location | Shelter addresses |
| `Building2` | Shelter | Shelter panel header |
| `Camera` | Photo | Photo attachment indicator |
| `CheckCircle2` / `XCircle` | Actions | Validate/reject buttons |

---

This serves as a complete technical reference for replicating the frontend. All values are pulled directly from the source code.

Add live sensor simulation
Add interactive flood map
Make dashboard mobile-responsive