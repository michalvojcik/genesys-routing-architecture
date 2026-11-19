resource "genesyscloud_routing_queue" "call_en" {
  name           = "Call_EN"
  description    = "Default English voice queue resolved dynamically via FindQueue('Call_' + Flow.Language)."
  scoring_method = "TimestampAndPriority"
}

resource "genesyscloud_routing_queue" "call_es" {
  name           = "Call_ES"
  description    = "Default Spanish voice queue resolved dynamically via FindQueue('Call_' + Flow.Language)."
  scoring_method = "TimestampAndPriority"
}

resource "genesyscloud_routing_queue" "call_de" {
  name           = "Call_DE"
  description    = "Default German voice queue resolved dynamically via FindQueue('Call_' + Flow.Language)."
  scoring_method = "TimestampAndPriority"
}

resource "genesyscloud_routing_queue" "call_ua" {
  name           = "Call_UA"
  description    = "Default Ukrainian voice queue resolved dynamically via FindQueue('Call_' + Flow.Language)."
  scoring_method = "TimestampAndPriority"
}

resource "genesyscloud_routing_queue" "call_ja" {
  name           = "Call_JA"
  description    = "Default Japanese voice queue resolved dynamically via FindQueue('Call_' + Flow.Language)."
  scoring_method = "TimestampAndPriority"
}