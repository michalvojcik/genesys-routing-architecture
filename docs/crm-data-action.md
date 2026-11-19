# Custom CRM Data Action Contract & Variable Mapping

This document defines the sanitized request/response JSON schemas, payload examples, and Architect variable mappings used across the **Identifier Input**, **Data Actions**, **Verification**, **Switch**, and **Menu / ACD Transfer** tasks.

> **Sanitization & Scope Note:** Endpoint contracts, field names, and sample values are generalized for portfolio use. When a custom CRM splits booking records, verification attributes, and interaction context across multiple backend services, this contract represents the normalized data shape consumed by the routing flow.

---

## 1. Request Contract (`inputSchema`)

Sent from the **Identifier Input** / **Data Actions** layer once the caller's reference identifier is collected.

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "BookingLookupRequest",
  "type": "object",
  "required": [
    "reference_id"
  ],
  "properties": {
    "reference_id": {
      "type": "string",
      "description": "Booking or order identifier collected in the Identifier Input task."
    }
  },
  "additionalProperties": false
}
```

### Example Request Payload

```json
{
  "reference_id": "BK-9482710"
}
```

---

## 2. Response Contract (`outputSchema`)

Structured with flat, top-level primitives so Genesys Cloud Data Actions can map fields directly into flow and task variables without complex nested expression parsing.

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "BookingVerificationResponse",
  "type": "object",
  "required": [
    "booking_found",
    "customer_phone_e164",
    "customer_dob",
    "minutes_to_event"
  ],
  "properties": {
    "booking_found": {
      "type": "boolean",
      "description": "Indicates whether a matching record exists for the supplied identifier."
    },
    "booking_status": {
      "type": "string",
      "description": "Current booking lifecycle status (e.g., CONFIRMED, MODIFIED, COMPLETED, CANCELLED)."
    },
    "customer_phone_e164": {
      "type": "string",
      "description": "Normalized E.164 phone number on file for ANI comparison."
    },
    "customer_dob": {
      "type": "string",
      "description": "Date of birth on file (e.g., YYYY-MM-DD) for fallback verification."
    },
    "minutes_to_event": {
      "type": "integer",
      "description": "Time to event in minutes (negative values indicate post-event)."
    },
    "is_on_site_urgent": {
      "type": "boolean",
      "description": "True when the caller is flagged as urgent and already on-site or at the venue."
    },
    "is_vip": {
      "type": "boolean",
      "description": "True if the customer holds VIP status."
    },
    "service_package": {
      "type": "string",
      "description": "Service package or tier identifier (e.g., STANDARD, PLUS, PRIORITY_PARTNER)."
    },
    "has_open_tickets": {
      "type": "boolean",
      "description": "True if active open support tickets exist for the customer or booking."
    },
    "is_repeat_caller": {
      "type": "boolean",
      "description": "True if recent repeat-contact context applies."
    }
  }
}
```

### Example Response Payload

```json
{
  "booking_found": true,
  "booking_status": "CONFIRMED",
  "customer_phone_e164": "+420600111222",
  "customer_dob": "1991-04-18",
  "minutes_to_event": 145,
  "is_on_site_urgent": true,
  "is_vip": false,
  "service_package": "PLUS",
  "has_open_tickets": false,
  "is_repeat_caller": false
}
```

---

## 3. Flow & Task Variable Mapping

| Response / Error Signal | Target Task(s) | Routing & Priority Behavior |
| :--- | :--- | :--- |
| `booking_found == false` or Data Action failure | **Identifier Input** | Increments attempt counter (`Attempts < 3`); plays `FindUserPrompt(Append(Flow.Language, "_identifier_incorrect"))` on retry, or plays double-check prompt and disconnects after 3 failed attempts. |
| `customer_phone_e164` | **Verification** | Compared against normalized ANI. A match marks verification complete without prompting for DOB; a mismatch enters the 3-attempt DOB loop. |
| `customer_dob` | **Verification** | Validated across up to 3 attempts when ANI does not match. Exhausting all 3 attempts sets the agent-script flag requiring full manual verification. |
| `minutes_to_event` | **Verification**, **Switch**, **Menu** | Drives proximity-based `Flow.Priority` calculation (increasing as time to event decreases) and selects the time-windowed menu (`> 2880` min, `< 2880` min, or `< 0` min). |
| `is_on_site_urgent`, `is_vip`, `service_package` | **Switch**, **Priority**, **Menu** | Contributes to `Flow.Priority` (applied at transfer via `10 + ToNum(Flow.Priority)` so high-urgency/on-site callers can surpass queue backlogs) and influences tier/survey handling. |
| `has_open_tickets`, `is_repeat_caller` | **Switch** | Evaluates whether to prompt about an open ticket or route directly toward ACD transfer vs. entering the time-based menu. |

---

## 4. Resilience Notes for Multi-Endpoint CRM Integration

* **Separate Core Lookup from Secondary Context:** Treat primary identifier validation/booking retrieval distinctly from auxiliary context enrichment (such as open ticket counts or repeat-caller flags) so a secondary timeout does not cause a valid caller to be rejected as having an invalid identifier.
* **Safe Defaults for Optional Context:** Default optional boolean/context flags safely (for example, `has_open_tickets = false`, `is_repeat_caller = false`) when non-blocking context endpoints are unavailable.
* **Consistent Phone Formatting:** Ensure `customer_phone_e164` is normalized to E.164 upstream or during response mapping so ANI equality checks remain reliable.