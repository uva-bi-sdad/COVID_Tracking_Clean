# COVID-19-COVID-Tracking-Clean

| **Documentation** | **Continous Integration** |
|:-----------------:|:-------------------------:|
| [![][ddi]][ddu]   | [![CI][bsi]][bsu]           |
| [![][li]][lu]     | [![CRON][croni]][cronu]           |

[ddi]: https://img.shields.io/badge/docs-dev-blue?style=plastic
[ddu]: https://uva-bi-sdad.github.io/COVID_Tracking_Clean/dev/
[li]: https://img.shields.io/github/license/uva-bi-sdad/COVID_Tracking_Clean?style=plastic
[lu]: https://tldrlegal.com/license/-isc-license

[bsi]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/workflows/CI/badge.svg
[bsu]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/actions?workflow=CI
[croni]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/workflows/CRON/badge.svg
[cronu]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/actions?workflow=CRON

This repository takes data from: [COVID19Tracking/covid-tracking-data](https://github.com/COVID19Tracking/covid-tracking-data) and provides
a clean table under `data/daily.tsv`.

The data schema is:
- `state::char(2) NOT null`
- `checkts::timestampt NOT null`
- `positive::integer`
- `negative::integer`
- `pending::integer`
- `hospitalized::integer`
- `death::integer`
- `grade::char(1)`

per the specification from the COVID Tracking Project [metadata](https://covidtracking.com/about-tracker).

It runs daily at `22:00:00.000 UTC`.

This is a solution mostly in response to [COVID19Tracking/covid-tracking-api#11](https://github.com/COVID19Tracking/covid-tracking-api/issues/11).
