# COVID-19-COVID-Tracking-Clean

This repository takes data from: [COVID19Tracking/covid-tracking-data](https://github.com/COVID19Tracking/covid-tracking-data) and provides
a clean table under `data/states.tsv`.

The data schema is:
- state::char(2) NOT null
- checkts::timestampt NOT null
- positive::integer
- negative::integer
- pending::integer
- hospitalized::integer
- death::integer
- grade::char(1)

per the specification from the COVID Tracking Project [metadata](https://covidtracking.com/about-tracker).

It runs daily at 20:00:00.000 UTC.

This is a solution mostly in response to [COVID19Tracking/covid-tracking-api#11](https://github.com/COVID19Tracking/covid-tracking-api/issues/11).
