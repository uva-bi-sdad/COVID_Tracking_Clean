var documenterSearchIndex = {"docs":
[{"location":"api/#API-1","page":"API","title":"API","text":"","category":"section"},{"location":"api/#Public-1","page":"API","title":"Public","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Modules = [COVID_Tracking_Clean]\nPrivate = false","category":"page"},{"location":"api/#COVID_Tracking_Clean.COVID_Tracking_Clean","page":"API","title":"COVID_Tracking_Clean.COVID_Tracking_Clean","text":"COVID_Tracking_Clean\n\nThis module is meant to clean the data from the COVID Tracking Project.\n\n\n\n\n\n","category":"module"},{"location":"api/#COVID_Tracking_Clean.main-Tuple{}","page":"API","title":"COVID_Tracking_Clean.main","text":"main()\n\nPerforms the action to refresh the data. Latest data will be written to data/latest.tsv\n\n\n\n\n\n","category":"method"},{"location":"api/#Private-1","page":"API","title":"Private","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Modules = [COVID_Tracking_Clean]\nPublic = false","category":"page"},{"location":"api/#COVID_Tracking_Clean.GITHUB_API_QUERY","page":"API","title":"COVID_Tracking_Clean.GITHUB_API_QUERY","text":"GITHUB_API_QUERY\n\nGitHub GraphQL query.\n\n\n\n\n\n","category":"constant"},{"location":"api/#COVID_Tracking_Clean.GITHUB_GRAPHQL_ENDPOINT","page":"API","title":"COVID_Tracking_Clean.GITHUB_GRAPHQL_ENDPOINT","text":"GITHUB_GRAPHQL_ENDPOINT::String = \"https://api.github.com/graphql\"\n\nGitHub API v4 GraphQL API endpoint.\n\n\n\n\n\n","category":"constant"},{"location":"api/#COVID_Tracking_Clean.GITHUB_REST_ENDPOINT","page":"API","title":"COVID_Tracking_Clean.GITHUB_REST_ENDPOINT","text":"GITHUB_REST_ENDPOINT::String = \"https://api.github.com\"\n\nGitHub API v3 RESTful root endpoint.\n\n\n\n\n\n","category":"constant"},{"location":"api/#COVID_Tracking_Clean.API_Limits","page":"API","title":"COVID_Tracking_Clean.API_Limits","text":"API_Limits\n\nGitHub API limits for a PersonalAccessToken.\n\nFields\n\ncore::Limits\nsearch::Limits\ngraphql::Limits\n\n\n\n\n\n","category":"type"},{"location":"api/#COVID_Tracking_Clean.GitHubPersonalAccessToken","page":"API","title":"COVID_Tracking_Clean.GitHubPersonalAccessToken","text":"GitHubPersonalAccessToken(login::AbstractString,\n                          token::AbstractString\n                          )::GitHubPersonalAccessToken\n\nA GitHub Personal Access Token\n\nFields\n\nlogin::String\ntoken::String\nclient::Client\nlimits::Limits\n\n\n\n\n\n","category":"type"},{"location":"api/#COVID_Tracking_Clean.Limits","page":"API","title":"COVID_Tracking_Clean.Limits","text":"Limits\n\nGitHub API limits.\n\nIt includes how many remaining queries are available for the current time period and when it resets.\n\nFields\n\nlimit::Int\nremaining::Int\nreset::ZonedDateTime\n\n\n\n\n\n","category":"type"},{"location":"api/#COVID_Tracking_Clean.Opt","page":"API","title":"COVID_Tracking_Clean.Opt","text":"Opt(login::AbstractString,\n    token::AbstractString;\n    db_usr::AbstractString = \"postgres\",\n    db_pwd::AbstractString = \"postgres\",\n    host::AbstractString = \"postgres\",\n    port::Integer = 5432,\n    dbname::AbstractString = \"postgres\",\n    schema::AbstractString = \"postgres\",\n    role::AbstractString = \"postgres\"\n    )::Opt\n\nStructure for passing arguments to functions.\n\nFields\n\nconn::Connection\nschema::String\nrole::String\npat::GitHubPersonalAccessToken\n\nExample\n\njulia> opt = Opt(\"Nosferican\",\n                 ENV[\"GITHUB_TOKEN\"],\n                 host = ENV[\"POSTGIS_HOST\"],\n                 port = parse(Int, ENV[\"POSTGIS_PORT\"]));\n\n\n\n\n\n\n","category":"type"},{"location":"api/#COVID_Tracking_Clean.find_shas","page":"API","title":"COVID_Tracking_Clean.find_shas","text":"find_shas(id::AbstractString = \"MDEwOlJlcG9zaXRvcnkyNDY0MTE2MDc=\",\n          directory::AbstractString = \"data\",\n          file::AbstractString = \"states_current.csv\",\n          just_last::Bool = false)\n\nReturn slug for the repository and SHA1 for the file at directory/file (all versions).\n\n\n\n\n\n","category":"function"},{"location":"api/#COVID_Tracking_Clean.get_sha","page":"API","title":"COVID_Tracking_Clean.get_sha","text":"get_sha(obj, directory::AbstractString = \"data\", file::AbstractString = \"states_current.csv\")::String\n\nNavigate the entries in the tree to find the SHA1 of the file at path (directory/file)\n\n\n\n\n\n","category":"function"},{"location":"api/#COVID_Tracking_Clean.get_tbl-Tuple{COVID_Tracking_Clean.GitHubPersonalAccessToken,AbstractString}","page":"API","title":"COVID_Tracking_Clean.get_tbl","text":"get_tbl(sha::AbstractString)\n\nUses the SHA1 to download from GitHub the version of COVID19Tracking/covid-tracking-data/data/states_current.csv\n\n\n\n\n\n","category":"method"},{"location":"api/#COVID_Tracking_Clean.graphql-Tuple{COVID_Tracking_Clean.GitHubPersonalAccessToken,AbstractString,Dict{String,V} where V}","page":"API","title":"COVID_Tracking_Clean.graphql","text":"graphql(obj::GitHubPersonalAccessToken,\n        operationName::AbstractString,\n        vars::Dict{String})\n\nReturn JSON of the GraphQL query.\n\n\n\n\n\n","category":"method"},{"location":"api/#COVID_Tracking_Clean.prune-Tuple{Any}","page":"API","title":"COVID_Tracking_Clean.prune","text":"prune(tbl)::DataFrame\n\nSimplifies the grade tsrange.\n\n\n\n\n\n","category":"method"},{"location":"api/#COVID_Tracking_Clean.restful-Tuple{COVID_Tracking_Clean.GitHubPersonalAccessToken,AbstractString}","page":"API","title":"COVID_Tracking_Clean.restful","text":"restful(obj::GitHubPersonalAccessToken,\n        endpoint::AbstractString;\n        method::AbstractString = \"GET\",\n        params::Dict{String} = Dict{String,String}(),\n)\n\nReturn response.\n\n\n\n\n\n","category":"method"},{"location":"api/#COVID_Tracking_Clean.states_daily-Tuple{}","page":"API","title":"COVID_Tracking_Clean.states_daily","text":"states_daily()\n\nUses the Covid Tracking API to return the states/daily table.\n\n\n\n\n\n","category":"method"},{"location":"#COVID-19-COVID-Tracking-Clean-1","page":"Home","title":"COVID-19-COVID-Tracking-Clean","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This repository takes data from: COVID19Tracking/covid-tracking-data and provides a clean table under data/daily.tsv.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The data schema is:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"state::char(2) NOT null\ncheckts::timestampt NOT null\npositive::integer\nnegative::integer\npending::integer\nhospitalized::integer\ndeath::integer\ngrade::char(1)","category":"page"},{"location":"#","page":"Home","title":"Home","text":"per the specification from the COVID Tracking Project metadata.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"It runs daily at 20:00:00.000 UTC.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"This is a solution mostly in response to COVID19Tracking/covid-tracking-api#11.","category":"page"}]
}
