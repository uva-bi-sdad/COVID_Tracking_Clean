# COVID-19-COVID-Tracking-Clean

This is a tool by the Network Systems Science and Advanced Computing (NSSAC) division of the Biocomplexity Institute & Initiative at University of Virginia.

For more infomation on our [COVID-19 Research](https://nssac.github.io/covid-19/index) visit our website.

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
