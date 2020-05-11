# COVID-19-COVID-Tracking-Clean

This is a tool by the Network Systems Science and Advanced Computing (NSSAC) division of the Biocomplexity Institute & Initiative at University of Virginia.

For more infomation on our [COVID-19 Research](https://nssac.github.io/covid-19/index) visit our website.

| **Documentation** |
|:-----------------:|
| [![][dsi]][dsu]   | 
| [![][ddi]][ddu]   | 
| [![][li]][lu]     | 

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

This repository maintained a daily up-to-date copy of the daily [COVID Tracking public API](https://covidtracking.com/api) Historic state data (`/daily`) endpoint enhanced with the state reporting data quality data. The `dataQualityGrade` variable has now been added to the endpoint. This repository still offers the historical data for before 2020-04-21. For data after 2020-04-21 one can use the API directly.
