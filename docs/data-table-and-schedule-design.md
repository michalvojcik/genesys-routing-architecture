# DNIS Data Table, Phone Normalization & Schedule Group Design

This document details how inbound phone numbers are normalized at call entry, how static DNIS-to-language/schedule metadata is stored in `DNIS_Routing_Config`, and how native Genesys Cloud Schedule Groups manage operating hours in the `Europe/Prague` timezone.

> **Scope & Sanitization Note:** Sample E.164 numbers and resource names are sanitized for portfolio use. All operating schedules are configured in `Europe/Prague` to match the reference Terraform configuration.

---

## 1. Phone Normalization Rules (`ANI` & `DNIS`)

Inbound telephony addresses in Genesys Cloud often arrive with URI prefixes (such as `tel:`) or formatting variations. Normalizing `DNIS` and `ANI` at the start of the flow ensures deterministic Data Table lookups and reliable ANI-to-CRM matching downstream.

* **DNIS (`Call.CalledAddress`):** Strip any `tel:` prefix (and non-digit characters except a leading `+`) so the value matches the canonical E.164 format stored in `DNIS_Routing_Config` (for example, `tel:+420200000001` becomes `+420200000001`).
* **ANI (`Call.Ani`):** Normalize to E.164 format as well so caller phone comparison in the **Verification** task does not fail due to `tel:` prefixes or formatting differences.
* **Unknown / Unmapped DNIS Handling:** If a lookup in `DNIS_Routing_Config` finds no matching row or errors out, fall back safely to `EN` (`Flow.Language = "EN"`) and route to the default English queue (`Call_EN`) rather than dropping the call unexpectedly.

---

## 2. DNIS Data Table Schema (`DNIS_Routing_Config`)

The `DNIS_Routing_Config` Data Table stores static routing metadata keyed by normalized E.164 DNIS, keeping language selection and schedule group resolution data-driven instead of hardcoded in Architect branches.

| Property Name | Type | Example Value | Role in Routing Flow |
| :--- | :--- | :--- | :--- |
| **`key`** | `string` | `+420200000001` | Primary lookup key matching normalized E.164 DNIS |
| **`language_name`** | `string` | `English` | Human-readable language label for logging/reporting/context |
| **`language_code`** | `string` | `EN` | Uppercase language code (`EN`, `ES`, `DE`, `UA`, `JA`) stored in `Flow.Language` for dynamic prompts (`*_welcome`, `*_identifier_incorrect`, menu/queue prompts) and dynamic queue lookup (`FindQueue("Call_" + Flow.Language)`) |
| **`dnis`** | `string` | `+420200000001` | Canonical E.164 DNIS value for explicit comparison/auditing |
| **`schedule_group_name`** | `string` | `SG_Support_EN` | Name of the Genesys Cloud Schedule Group evaluated in the **Opening Hours** task |

### Schema Maintenance Notes
* **Immutability:** In Genesys Cloud Data Tables, existing custom properties cannot be deleted in place. If you need to retire or rename a column, create a new Data Table version and update the flow reference cleanly.
* **Casing Consistency:** Keep `language_code` in uppercase (`EN`, `ES`, `DE`, `UA`, `JA`) to match queue names (`Call_EN`, `Call_ES`, `Call_DE`, `Call_UA`, `Call_JA`) and dynamic prompt naming conventions without extra case-conversion steps.

---

## 3. `Europe/Prague` Schedule Groups & Queues

Storing raw operating hours in a Data Table breaks across Daylight Saving Time (DST) transitions and holiday exceptions. Native Genesys Cloud **Schedules** and **Schedule Groups** evaluate open/closed status automatically in `Europe/Prague`.

### Configured Operating Schedules (`Europe/Prague`)

| Language | Code | Schedule Group | Operating Window (`Europe/Prague`) | Target Queue |
| :--- | :--- | :--- | :--- | :--- |
| **English** | `EN` | `SG_Support_EN` | 24/7 (`FREQ=DAILY`) | `Call_EN` |
| **Spanish** | `ES` | `SG_Support_ES` | Mon–Fri, `09:00` – `20:00` | `Call_ES` |
| **German** | `DE` | `SG_Support_DE` | Mon–Fri, `09:00` – `17:00` | `Call_DE` |
| **Ukrainian** | `UA` | `SG_Support_UA` | Mon–Fri, `08:00` – `17:00` | `Call_UA` |
| **Japanese** | `JA` | `SG_Support_JA` | Mon–Fri, `02:00` – `10:00` | `Call_JA` |

### How Opening Hours Interact with `Flow.Language`
1. **Welcome Prompt First:** After reading `Flow.Language` and `schedule_group_name` from `DNIS_Routing_Config`, the flow plays `FindUserPrompt(Append(Flow.Language, "_welcome"))` and enters the **Opening Hours** reusable task.
2. **Line Open:** Offers the English option (for instance, when callers prefer English or want to avoid wait times on a specific line). Selecting English sets `Flow.Language = "EN"`; otherwise `Flow.Language` stays as-is and proceeds to **Identifier Input**.
3. **Line Closed:**
   * If `Flow.Language` is already `EN`, plays the closed prompt and disconnects.
   * If `Flow.Language` is not `EN`, informs the caller that the line is closed and offers to continue in English. If they choose English, `Flow.Language` becomes `"EN"` and routing continues; if they do not select English, the flow plays the prompt stating their language cannot be supported right now and disconnects.
