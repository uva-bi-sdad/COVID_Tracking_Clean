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
function main(deploy::Bool = true)
    ENV["PGHOST"] = get(ENV, "PGHOST", "localhost")
    ENV["PGPORT"] = get(ENV, "PGPORT", "5432")
    ENV["PAT"] = get(ENV, "PAT", "")

    opt = Opt("Nosferican",
              ENV["PAT"],
              host = ENV["PGHOST"],
              port = parse(Int, ENV["PGPORT"]))
    execute(opt.conn,
            """
            CREATE EXTENSION IF NOT EXISTS btree_gist;
            DROP TABLE IF EXISTS daily CASCADE;
            CREATE TABLE IF NOT EXISTS daily (
              state char(2) NOT NULL,
              checkts timestamp NOT NULL,
              positive int,
              negative int,
              pending int,
              hospitalized_currently int,
              hospitalized_cumulative int,
              icu_currently int,
              icu_cumulative int,
              ventilation_currently int,
              ventilation_cumulative int,
              recovered int,
              death int,
              EXCLUDE USING gist (state WITH =, checkts WITH =)
            );
            DROP TABLE IF EXISTS qc CASCADE;
            CREATE TABLE IF NOT EXISTS qc (
              state char(2) NOT NULL,
              during timestamp NOT NULL,
              data_quality_grade varchar(2) NOT NULL
            );
            """
            )
    shas = find_shas(opt.pat)
    qc = vcat((get_tbl(opt.pat, sha) for sha in shas)..., cols = :union)
    qc[!,:checkTimeEt] = astimezone.(qc.checkTimeEt, utc_tz)

    # vscodedisplay(data)

    daily = states_daily()

    execute(opt.conn, "BEGIN;")
    load!(daily, opt.conn, "INSERT INTO daily VALUES($(join(("\$$i" for i in 1:13), ',')));")
    execute(opt.conn, "COMMIT;")

    execute(opt.conn, "BEGIN;")
    load!(qc, opt.conn, "INSERT INTO qc VALUES($(join(("\$$i" for i in 1:3), ',')));")
    execute(opt.conn, "COMMIT;")

    output = execute(
        opt.conn,
        """
        DROP SEQUENCE IF EXISTS serial CASCADE;
        CREATE TEMP SEQUENCE serial START WITH 1;
        SELECT
          nextval('serial');
        CREATE MATERIALIZED VIEW IF NOT EXISTS data_quality_grades AS (
            WITH A AS (
              SELECT
                DISTINCT ON (state, during) state,
                during,
                data_quality_grade
              FROM qc
              ORDER BY
                state ASC,
                during ASC
            ),
            B AS (
              SELECT
                state,
                during,
                data_quality_grade,
                LAG(data_quality_grade) OVER (
                  PARTITION BY state
                  ORDER BY
                    during ASC
                ) AS prev
              FROM A
            ),
            C AS (
              SELECT
                state,
                during,
                data_quality_grade,
                CASE
                  WHEN prev IS null
                  OR prev <> data_quality_grade THEN nextval('serial')
                  ELSE currval('serial')
                END AS grp
              FROM B
            ),
            D AS (
              SELECT
                state,
                MIN(during) AS start_ts,
                MAX(during) AS end_ts,
                data_quality_grade
              FROM C
              GROUP BY
                state,
                data_quality_grade,
                grp
            ),
            E AS (
              SELECT
                *,
                LEAD(start_ts) OVER (
                  PARTITION BY state
                  ORDER BY
                    start_ts
                ) AS until_ts
              FROM D
            )
            SELECT
              state,
              CASE
                WHEN until_ts IS NOT NULL THEN tsrange(start_ts, until_ts)
                WHEN start_ts = end_ts THEN tsrange(start_ts, date_trunc('second', NOW() :: timestamp))
                ELSE tsrange(start_ts, end_ts)
              END AS during,
              data_quality_grade
            FROM E
            ORDER BY
              state ASC,
              during ASC
          );
        SELECT
          A.*,
          B.data_quality_grade
        FROM public.daily A
        LEFT JOIN public.data_quality_grades B ON A.state = B.state
          AND B.during @ > A.checkts
        ORDER BY
          state ASC,
          checkts ASC;
        """) |>
        rowtable
    content = base64encode(take!(CSV.write(IOBuffer(), output, delim = '\t')));
    if deploy
        restful(opt.pat, "repos/uva-bi-sdad/COVID_Tracking_Clean/contents/data/daily.tsv",
                method = "PUT",
                params = Dict("message" => "Updating data/states.tsv at $(now(utc_tz))",
                              "content" => content,
                              "sha" => find_shas(opt.pat, "MDEwOlJlcG9zaXRvcnkyNTIwNDUwOTQ=", "data", "daily.tsv", true)))
    end
    true
end

export main
end
