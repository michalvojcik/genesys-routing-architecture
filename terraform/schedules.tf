resource "genesyscloud_architect_schedules" "support_en_24_7" {
  name        = "Sched_Support_EN_24x7"
  description = "24/7 operating schedule for English support."
  start       = "2026-01-05T00:00:00"
  end         = "2026-01-06T00:00:00"
  rrule       = "RRULE:FREQ=DAILY"
}

resource "genesyscloud_architect_schedules" "support_es_mf" {
  name        = "Sched_Support_ES_MF_0900_2000"
  description = "Monday-Friday 09:00-20:00 schedule for Spanish support."
  start       = "2026-01-05T09:00:00"
  end         = "2026-01-05T20:00:00"
  rrule       = "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
}

resource "genesyscloud_architect_schedules" "support_de_mf" {
  name        = "Sched_Support_DE_MF_0900_1700"
  description = "Monday-Friday 09:00-17:00 schedule for German support."
  start       = "2026-01-05T09:00:00"
  end         = "2026-01-05T17:00:00"
  rrule       = "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
}

resource "genesyscloud_architect_schedules" "support_ua_mf" {
  name        = "Sched_Support_UA_MF_0800_1700"
  description = "Monday-Friday 08:00-17:00 schedule for Ukrainian support."
  start       = "2026-01-05T08:00:00"
  end         = "2026-01-05T17:00:00"
  rrule       = "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
}

resource "genesyscloud_architect_schedules" "support_ja_mf" {
  name        = "Sched_Support_JA_MF_0200_1000"
  description = "Monday-Friday 02:00-10:00 schedule for Japanese support."
  start       = "2026-01-05T02:00:00"
  end         = "2026-01-05T10:00:00"
  rrule       = "RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
}

resource "genesyscloud_architect_schedulegroups" "support_en" {
  name              = "SG_Support_EN"
  description       = "Schedule group for English support line (Europe/Prague)."
  time_zone         = "Europe/Prague"
  open_schedules    = [genesyscloud_architect_schedules.support_en_24_7.id]
  closed_schedules  = []
  holiday_schedules = []
}

resource "genesyscloud_architect_schedulegroups" "support_es" {
  name              = "SG_Support_ES"
  description       = "Schedule group for Spanish support line (Europe/Prague)."
  time_zone         = "Europe/Prague"
  open_schedules    = [genesyscloud_architect_schedules.support_es_mf.id]
  closed_schedules  = []
  holiday_schedules = []
}

resource "genesyscloud_architect_schedulegroups" "support_de" {
  name              = "SG_Support_DE"
  description       = "Schedule group for German support line (Europe/Prague)."
  time_zone         = "Europe/Prague"
  open_schedules    = [genesyscloud_architect_schedules.support_de_mf.id]
  closed_schedules  = []
  holiday_schedules = []
}

resource "genesyscloud_architect_schedulegroups" "support_ua" {
  name              = "SG_Support_UA"
  description       = "Schedule group for Ukrainian support line (Europe/Prague)."
  time_zone         = "Europe/Prague"
  open_schedules    = [genesyscloud_architect_schedules.support_ua_mf.id]
  closed_schedules  = []
  holiday_schedules = []
}

resource "genesyscloud_architect_schedulegroups" "support_ja" {
  name              = "SG_Support_JA"
  description       = "Schedule group for Japanese support line (Europe/Prague)."
  time_zone         = "Europe/Prague"
  open_schedules    = [genesyscloud_architect_schedules.support_ja_mf.id]
  closed_schedules  = []
  holiday_schedules = []
}