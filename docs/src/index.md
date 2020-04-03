# COVID-19-COVID-Tracking-Clean

This is a tool by the Network Systems Science and Advanced Computing (NSSAC) division of the Biocomplexity Institute & Initiative at University of Virginia.

For more infomation on our [COVID-19 Research](https://nssac.github.io/covid-19/index) visit our website.

| **Documentation** | **Continous Integration**        |
|:-----------------:|:--------------------------------:|
| [![][dsi]][dsu]   | [![CI][bsi]][bsu]                |
| [![][ddi]][ddu]   | [![CRON][croni]][cronu]          |
| [![][li]][lu]     | [![codecov][codecovi]][codecovu] |

[ddi]: https://img.shields.io/badge/docs-dev-blue?style=plastic
[ddu]: https://uva-bi-sdad.github.io/COVID_Tracking_Clean/dev/
[dsi]: https://img.shields.io/badge/docs-stable-blue?style=plastic
[dsu]: https://uva-bi-sdad.github.io/COVID_Tracking_Clean/stable/
[li]: https://img.shields.io/github/license/uva-bi-sdad/COVID_Tracking_Clean?style=plastic
[lu]: https://choosealicense.com/licenses/zlib/

[bsi]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/workflows/CI/badge.svg
[bsu]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/actions?workflow=CI
[croni]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/workflows/CRON/badge.svg
[cronu]: https://github.com/uva-bi-sdad/COVID_Tracking_Clean/actions?workflow=CRON

[codecovi]: https://codecov.io/gh/uva-bi-sdad/COVID_Tracking_Clean/branch/master/graph/badge.svg
[codecovu]: https://codecov.io/gh/uva-bi-sdad/COVID_Tracking_Clean

This repository takes data from: [COVID Tracking Data (CSV)](https://github.com/COVID19Tracking/covid-tracking-data) and provides a clean table under `data/daily.tsv`.

## Data schema

- `state::char(2) NOT null`
- `checkts::timestampt NOT null`
- `positive::integer`
- `negative::integer`
- `pending::integer`
- `hospitalized::integer`
- `death::integer`
- `grade::char(1)`

per the specification from the COVID Tracking Project [metadata](https://covidtracking.com/about-tracker).

It runs daily at `22:00:00.000 UTC` (i.e., after 17:00 `America/New_York` when the data is updated daily)

## Related issues:
- [Adding grade and score to states/daily](https://github.com/COVID19Tracking/covid-tracking-api/issues/11)
- [Add state grades to historical data](https://github.com/COVID19Tracking/covid-tracking-data/issues/22)
- [api/state/daily Is out of date with spreadsheet](https://github.com/COVID19Tracking/covid-tracking-api/issues/30)
