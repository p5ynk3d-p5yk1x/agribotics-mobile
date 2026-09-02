# Localization text audit

The localization sweep covers every presentation surface under `lib/features/**/presentation`
and every shared display widget under `lib/shared/widgets`.

## Page groups

ARB keys are prefixed by feature and page so related copy remains adjacent and searchable:

- `auth_login_page_*`
- `language_language_selection_page_*`
- `land_land_dashboard_page_*`, `land_land_selection_page_*`, and land widgets
- `disease_disease_detection_page_*`, `disease_disease_history_*`, and `disease_disease_map_*`
- `estate_estate_identity_page_*` and `estate_sector_detail_page_*`
- `identify_identify_page_*`
- `market_market_page_*` and `market_product_detail_page_*`
- `settings_settings_page_*`
- `soil_nutrient_detection_page_*`, `soil_soil_history_*`, `soil_soil_map_*`, and `soil_soil_report_*`
- `weeds_weed_detection_*`, `weeds_weed_diagnosis_*`, `weeds_weed_history_*`, `weeds_weed_map_*`, and `weeds_weed_detail_*`
- `shared_*` for reusable navigation, badges, timelines, and common statuses
- `*_messages_*` for errors or statuses originating below the presentation layer

Each English page key has an `@key` description naming the owning page. All six catalogs
have exactly the same message-key set.

## Deliberate omissions

The runtime translator returns unmatched values unchanged. This is intentional for values
that should not be translated:

- vegetation and soil indices such as NDVI, EVI, NPK, N, P, and K;
- identifiers, record IDs, coordinates, percentages, dates, currency values, and page counts;
- units and standard abbreviations such as JSON, CSV, GPS, AI, OAuth, pH, kg/ha, cm, and ha;
- user/server supplied names and measurements;
- scientific, cultivar, product, and trademark names where translating would make the name inaccurate.

All surrounding explanatory labels and sentences are localized independently.

## Translation review

Translations use agriculture-specific terms for land, soil, nutrients, crop health, disease,
weather, marketplace, diagnostics, and treatment actions. Navigation and action terminology is
kept consistent between pages. Native language names remain visible on the selector even before
a locale has been chosen.
