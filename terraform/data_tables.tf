resource "genesyscloud_architect_datatable" "dnis_routing_config" {
  name        = "DNIS_Routing_Config"
  description = "Maps normalized E.164 DNIS keys to language metadata and schedule group names."

  properties {
    name  = "key"
    type  = "string"
    title = "Lookup Key (Normalized DNIS)"
  }

  properties {
    name  = "language_name"
    type  = "string"
    title = "Language Name"
  }

  properties {
    name  = "language_code"
    type  = "string"
    title = "Language Code"
  }

  properties {
    name  = "dnis"
    type  = "string"
    title = "DNIS (E.164)"
  }

  properties {
    name  = "schedule_group_name"
    type  = "string"
    title = "Schedule Group Name"
  }
}

resource "genesyscloud_architect_datatable_row" "dnis_en" {
  datatable_id = genesyscloud_architect_datatable.dnis_routing_config.id
  key_value    = "+420200000001"

  properties_json = jsonencode({
    key                 = "+420200000001"
    language_name       = "English"
    language_code       = "EN"
    dnis                = "+420200000001"
    schedule_group_name = genesyscloud_architect_schedulegroups.support_en.name
  })
}

resource "genesyscloud_architect_datatable_row" "dnis_es" {
  datatable_id = genesyscloud_architect_datatable.dnis_routing_config.id
  key_value    = "+420200000002"

  properties_json = jsonencode({
    key                 = "+420200000002"
    language_name       = "Spanish"
    language_code       = "ES"
    dnis                = "+420200000002"
    schedule_group_name = genesyscloud_architect_schedulegroups.support_es.name
  })
}

resource "genesyscloud_architect_datatable_row" "dnis_de" {
  datatable_id = genesyscloud_architect_datatable.dnis_routing_config.id
  key_value    = "+420200000003"

  properties_json = jsonencode({
    key                 = "+420200000003"
    language_name       = "German"
    language_code       = "DE"
    dnis                = "+420200000003"
    schedule_group_name = genesyscloud_architect_schedulegroups.support_de.name
  })
}

resource "genesyscloud_architect_datatable_row" "dnis_ua" {
  datatable_id = genesyscloud_architect_datatable.dnis_routing_config.id
  key_value    = "+420200000004"

  properties_json = jsonencode({
    key                 = "+420200000004"
    language_name       = "Ukrainian"
    language_code       = "UA"
    dnis                = "+420200000004"
    schedule_group_name = genesyscloud_architect_schedulegroups.support_ua.name
  })
}

resource "genesyscloud_architect_datatable_row" "dnis_ja" {
  datatable_id = genesyscloud_architect_datatable.dnis_routing_config.id
  key_value    = "+420200000005"

  properties_json = jsonencode({
    key                 = "+420200000005"
    language_name       = "Japanese"
    language_code       = "JA"
    dnis                = "+420200000005"
    schedule_group_name = genesyscloud_architect_schedulegroups.support_ja.name
  })
}