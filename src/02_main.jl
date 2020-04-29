"""
    get_sha(obj, directory::AbstractString = "data", file::AbstractString = "states_current.csv")::String

Navigate the entries in the tree to find the SHA1 of the file at path (directory/file)
"""
function get_sha(obj, directory::AbstractString = "data", file::AbstractString = "states_current.csv")::String
    node = obj.node.tree.entries
    node_ = node[findfirst(elem -> elem.name == directory, node)].object.entries
    node_[findfirst(elem -> elem.name == file, node_)].oid
end
"""
    find_shas(id::AbstractString = "MDEwOlJlcG9zaXRvcnkyNDY0MTE2MDc=",
              directory::AbstractString = "data",
              file::AbstractString = "states_current.csv",
              just_last::Bool = false)

Return slug for the repository and SHA1 for the file at directory/file (all versions).
"""
function find_shas(obj::GitHubPersonalAccessToken,
                   id::AbstractString = "MDEwOlJlcG9zaXRvcnkyNDY0MTE2MDc=",
                   directory::AbstractString = "data",
                   file::AbstractString = "states_current.csv",
                   just_last::Bool = false)
    # For testing
    # obj = opt.pat
    # id = "MDEwOlJlcG9zaXRvcnkyNDY0MTE2MDc="
    # directory = "data"
    # file = "states_current.csv"
    # just_last = false
    # The node ID is the repository with slug COVID19Tracking/covid-tracking-data
    # The file that has the information we want is at: data/states_current.csv

    # uva-bi-sdad/COVID_Tracking_Clean
    # id = "MDEwOlJlcG9zaXRvcnkyNTIwNDUwOTQ="
    # directory = "data"
    # file = "daily.tsv"
    # just_last = true
    vars = Dict("id" => id,
                "path" => "$directory/$file",
                # When first started publishing the quality checks
                "since" => "2020-03-20T23:00:07Z",
                "cursor" => nothing,
                "first" => just_last ? 1 : 100)
    # The initial request finds out how many commits are for the file
    # and the SHA1 for the last 100 commits affecting that file
    response = graphql(obj, "Magic", vars, GITHUB_API_QUERY = GITHUB_API_QUERY)
    json = JSON3.read(response.Data)
    # Get the slug just in case
    slug = json.data.node.nameWithOwner
    # We store the total count of commits for a final check
    total = json.data.node.defaultBranchRef.target.history.totalCount
    # We get the SHA1 for each of the file/versions
    shas = get_sha.(json.data.node.defaultBranchRef.target.history.edges, directory, file)
    just_last && return shas[1]
    # This strategy is valid while the total number of commits is below 1,000
    @assert total ≤ 1_000 "Code needs to be updated for more than 1,000 commits!"
    # If there are more than 100 commits we paginate
    while json.data.node.defaultBranchRef.target.history.pageInfo.hasNextPage
        response = graphql(opt.pat,
                           "Magic",
                           merge(vars, Dict("cursor" => json.data.node.defaultBranchRef.target.history.pageInfo.endCursor)),
                           GITHUB_API_QUERY = GITHUB_API_QUERY)
        json = JSON3.read(response.Data)
        append!(shas, get_sha.(json.data.node.defaultBranchRef.target.history.edges, directory, file))
    end
    # Verify the total number of SHA1 matches the number of commits
    @assert slug == "COVID19Tracking/covid-tracking-data" "Repository has been renamed or moved!"
    @assert total == length(shas) "Some commit SHA1 were not collected!"
    shas
end
"""
    get_tbl(sha::AbstractString)

Uses the SHA1 to download from GitHub the version of [COVID19Tracking/covid-tracking-data/data/states_current.csv](https://github.com/COVID19Tracking/covid-tracking-data/blob/master/data/states_current.csv)
"""
function get_tbl(obj::GitHubPersonalAccessToken, sha::AbstractString)
    response = restful(obj, "repos/COVID19Tracking/covid-tracking-data/git/blobs/$sha")
    @assert response.status == 200
    json = JSON3.read(response.body)
    data = File(base64decode(json.content),
                # select = [:state, :positiveScore, :negativeScore, :negativeRegularScore, :commercialScore, :checkTimeEt, :dataQualityGrade]) |>
    ) |>
        DataFrame
        names(data)
    colnames = names(data)
    if :dataQualityGrade in colnames
        data = dropmissing!(data[!,[:state, :checkTimeEt, :dataQualityGrade]])
        data[!,:checkTimeEt] = ZonedDateTime.(string.("2020/", data.checkTimeEt, " America/New_York"),
                                              COVID_TRACKING_DT)
    elseif all(elem -> elem ∈ colnames, (:positiveScore, :negativeScore, :negativeRegularScore, :commercialScore))
        data = dropmissing!(data[!,[:state, :checkTimeEt, :positiveScore, :negativeScore, :negativeRegularScore, :commercialScore]])
        data[!,:positiveScore] = isone.(data.positiveScore)
        data[!,:negativeScore] = isone.(data.negativeScore)
        data[!,:negativeRegularScore] = isone.(data.negativeRegularScore)
        data[!,:commercialScore] = isone.(data.commercialScore)
        data[!,:checkTimeEt] = ZonedDateTime.(string.("2020/", data.checkTimeEt, " America/New_York"),
                                              COVID_TRACKING_DT)
        data[!,:dataQualityGrade] = get.(Ref(Dict(1 => "D", 2 => "C", 3 => "B", 4 => "A")),
                              data.positiveScore + data.negativeScore + data.negativeRegularScore + data.commercialScore,
                              missing)
        data = data[!,[:state, :checkTimeEt, :dataQualityGrade]]
    else
        data = DataFrame()
    end
    data
end
"""
    states_daily()

Uses the Covid Tracking API to return the states/daily table.
"""
function states_daily()
    response = request("GET", "https://covidtracking.com/api/states/daily.csv")
    @assert response.status == 200
    data = File(response.body) |>
        (tbl -> select(tbl, :state, :dateChecked,
                            :positive, :negative, :pending,
                            :hospitalizedCurrently, :hospitalizedCumulative,
                            :inIcuCurrently, :inIcuCumulative,
                            :onVentilatorCurrently, :onVentilatorCumulative,
                            :recovered, :death)) |>
        DataFrame
    data[!,:dateChecked] = ZonedDateTime.(data.dateChecked, DateFormat("yyyy-mm-ddTHH:MM:SSz"))
    rename!(data, :dateChecked => :checkts,
                  :hospitalizedCurrently => :hospitalized_currently,
                  :hospitalizedCumulative => :hospitalized_cumulative,
                  :inIcuCurrently => :icu_currently,
                  :inIcuCumulative => :icu_cumulative,
                  :onVentilatorCurrently => :ventilator_currently,
                  :onVentilatorCumulative => :ventilator_cumulative,
                  )
end
