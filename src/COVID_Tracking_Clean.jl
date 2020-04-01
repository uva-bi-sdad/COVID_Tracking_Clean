"""
    COVID_Tracking_Clean

This module is meant to clean the data from the COVID Tracking Project.
"""
module COVID_Tracking_Clean
using Diana: Client, GraphQLClient,
            # HTTP
            HTTP.request
using JSON3: JSON3
using LibPQ: Connection, execute, load!,
             # TimeZones
             ZonedDateTime,
             TimeZones.utc_tz,
             # Dates
             DateTime,
             Dates.format,
             Dates.DateFormat,
             unix2datetime,
             now,
             astimezone,
             Interval
using Parameters: @unpack
using TableOperations: select
using CSV: CSV, File,
    # Tables
    Tables.schema,
    Tables.rowtable,
    # DataFrames
    DataFrame,
    categorical!,
    dropmissing!,
    rename!,
    by
using Base64: base64decode, base64encode
import Base: show, summary
# Constants
const COVID_TRACKING_DT = DateFormat("y/m/d HH:MM Z")

for (root, dirs, files) in walkdir(joinpath(@__DIR__))
    for file in files
        isequal("COVID_Tracking_Clean.jl", file) || include(joinpath(root, file))
    end
end

"""
    main()

Performs the action to refresh the data.
Latest data will be written to data/latest.tsv
"""
function main()
    ENV["POSTGIS_HOST"] = get(ENV, "POSTGIS_HOST", "localhost")
    ENV["POSTGIS_PORT"] = get(ENV, "POSTGIS_PORT", "5432")
    ENV["PAT"] = get(ENV, "PAT", "")

    opt = Opt("Nosferican",
              ENV["GITHUB_TOKEN"],
              host = ENV["POSTGIS_HOST"],
              port = parse(Int, ENV["POSTGIS_PORT"]))
    execute(opt.conn,
    """
    CREATE TABLE IF NOT EXISTS daily (
        state char(2) NOT NULL,
        checkts timestamp NOT NULL,
        positive int,
        negative int,
        pending int,
        hospitalized int,
        death int,
        EXCLUDE USING gist (state WITH =, checkts WITH =)
    );
    CREATE TABLE IF NOT EXISTS qc (
        state char(2) NOT NULL,
        during tsrange NOT NULL,
        grade char(1) NOT NULL,
        EXCLUDE USING gist (state WITH =, during WITH &&)
    );
    """
    )
    shas = find_shas(opt.pat)
    qc = vcat((get_tbl(opt.pat, sha) for sha in shas)..., cols = :union)
    qc = by(qc[:,[:state, :checkTimeEt, :grade]], :state, prune)
    qc[!,:checkTimeEt] = astimezone.(qc.checkTimeEt, utc_tz)
    rename!(qc, :checkTimeEt => :checkts)
    qc[!,:checkts] = replace.(string.(qc.checkts), " .." => ",")
    sort!(qc, [:state, :checkts, :grade])

    daily = states_daily()

    execute(opt.conn, "BEGIN;")
    load!(daily, opt.conn, "INSERT INTO daily VALUES($(join(("\$$i" for i in 1:7), ',')));")
    execute(opt.conn, "COMMIT;")

    execute(opt.conn, "BEGIN;")
    load!(qc[:,[:state,:checkts,:grade]], opt.conn, "INSERT INTO qc VALUES($(join(("\$$i" for i in 1:3), ',')));")
    execute(opt.conn, "COMMIT;")

    output = execute(opt.conn,
                     """
                     SELECT A.*, B.grade
                        FROM daily A
                     LEFT JOIN qc B
                        ON A.state = B.state AND B.during @> A.checkts
                     ORDER BY state ASC, checkts ASC;
                     """) |>
        rowtable
    content = base64encode(take!(CSV.write(IOBuffer(), output, delim = '\t')));
    restful(opt.pat, "repos/uva-bi-sdad/COVID_Tracking_Clean/contents/data/daily.tsv",
            method = "PUT",
            params = Dict("message" => "Updating data/states.tsv at $(now(utc_tz))",
                          "content" => content,
                          "sha" => find_shas(opt.pat, "MDEwOlJlcG9zaXRvcnkyNTIwNDUwOTQ=", "data", "daily.tsv", true)))
    true
end

export main
end
