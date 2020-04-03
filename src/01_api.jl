# GitHub API related
"""
    GITHUB_REST_ENDPOINT::String = "https://api.github.com"
        
GitHub API v3 RESTful root endpoint.
"""
const GITHUB_REST_ENDPOINT = "https://api.github.com"
"""
    GITHUB_GRAPHQL_ENDPOINT::String = "https://api.github.com/graphql"
        
GitHub API v4 GraphQL API endpoint.
"""
const GITHUB_GRAPHQL_ENDPOINT = "https://api.github.com/graphql"
"""
    GITHUB_API_QUERY

GitHub GraphQL query.
"""
const GITHUB_API_QUERY =
"""
query Magic(\$id: ID!, \$path: String!, \$since: GitTimestamp!, \$first: Int!, \$cursor: String) {
  node(id: \$id) {
    ... on Repository {
      nameWithOwner
      defaultBranchRef {
        target {
          ... on Commit {
            ... History
          }
        }
      }
    }
  }
}
fragment History on Commit {
  history(path: \$path, since: \$since, first: \$first, after: \$cursor) {
    totalCount
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        tree {
          entries {
            name
            object {
              ... on Tree {
                entries {
                  name
                  oid
                }
              }
            }
          }
        }
      }
    }
  }
}
""" |>
    (obj -> replace(obj, r"\s+" => " ")) |>
    strip |>
    string
# Structs
"""
    Limits

GitHub API limits.

It includes how many remaining queries are available for the current time period and when it resets.

# Fields
- `limit::Int`
- `remaining::Int`
- `reset::ZonedDateTime`
"""
mutable struct Limits
    limit::Int
    remaining::Int
    reset::ZonedDateTime
end
"""
    API_Limits

GitHub API limits for a PersonalAccessToken.

# Fields
- `core::Limits`
- `search::Limits`
- `graphql::Limits`
"""
mutable struct API_Limits
    core::Limits
    search::Limits
    graphql::Limits
end
"""
    GitHubPersonalAccessToken(login::AbstractString,
                              token::AbstractString
                              )::GitHubPersonalAccessToken

A GitHub Personal Access Token

# Fields

- `login::String`
- `token::String`
- `client::Client`
- `limits::Limits`
"""
struct GitHubPersonalAccessToken
    login::String
    token::String
    client::Client
    limits::API_Limits
    function GitHubPersonalAccessToken(login::AbstractString, token::AbstractString)
        client = GraphQLClient(
            GITHUB_GRAPHQL_ENDPOINT,
            auth = "bearer $token",
            headers = Dict("User-Agent" => login),
        )
        # Dummy values
        limits = API_Limits(Limits(0, 0, now(utc_tz)),
                            Limits(0, 0, now(utc_tz)),
                            Limits(0, 0, now(utc_tz)))
        output = new(login, token, client, limits)
        # Update dummy values for actual ones
        update!(output)
    end
end
summary(io::IO, obj::GitHubPersonalAccessToken) =
    println(io, "GitHub Personal Access Token")
function show(io::IO, obj::GitHubPersonalAccessToken)
    print(io, summary(obj))
    println(io, "  login: $(obj.login)")
    println(io, "  core remaining: $(obj.limits.core.remaining)")
    println(io, "  core reset: $(obj.limits.core.reset)")
    println(io, "  graphql remaining: $(obj.limits.graphql.remaining)")
    println(io, "  graphql reset: $(obj.limits.graphql.reset)")
end
function update!(obj::GitHubPersonalAccessToken)
    response = request(
        "GET",
        "$GITHUB_REST_ENDPOINT/rate_limit",
        [
            "Accept" => "application/vnd.github.v3+json",
            "User-Agent" => obj.login,
            "Authorization" => "token $(obj.token)",
        ],
    )
    json = JSON3.read(response.body).resources
    obj.limits.core.remaining = json.core.remaining
    obj.limits.core.reset = ZonedDateTime(unix2datetime(json.core.reset), utc_tz)
    obj.limits.search.remaining = json.search.remaining
    obj.limits.search.reset = ZonedDateTime(unix2datetime(json.search.reset), utc_tz)
    obj.limits.graphql.remaining = json.graphql.remaining
    obj.limits.graphql.reset = ZonedDateTime(unix2datetime(json.graphql.reset), utc_tz)
    obj
end
"""
    graphql(obj::GitHubPersonalAccessToken,
            operationName::AbstractString,
            vars::Dict{String})

Return JSON of the GraphQL query.
"""
function graphql(
    obj::GitHubPersonalAccessToken,
    operationName::AbstractString,
    vars::Dict{String};
    GITHUB_API_QUERY = GITHUB_API_QUERY
)
    update!(obj)
    if iszero(obj.limits.graphql.remaining)
        w = obj.limits.graphql.reset - now(utc_tz)
        sleep(max(w, zero(w)))
        obj.limits.remaining = obj.limits.graphql.limit
    end
    result = try
        result = obj.client.Query(GITHUB_API_QUERY, operationName = operationName, vars = vars)
        @assert result.Info.status == 200
        # If the cost is higher than the current remaining, it will return a 200 with the API rate limit message
        if result.Data == "{\"errors\":[{\"type\":\"RATE_LIMITED\",\"message\":\"API rate limit exceeded\"}]}"
            w = obj.limits.graphql.reset - now(utc_tz)
            sleep(max(w, zero(w)))
            result = obj.client.Query(GITHUB_API_QUERY, operationName = operationName, vars = vars)
            @assert result.Info.status == 200
        end
        result
    catch err
        # If the query triggered an abuse behavior it will check for a retry_after
        retry_after = (x[2] for x ∈ values(err.response.headers) if x[1] == "Retry-After")
        isempty(retry_after) || sleep(parse(Int, first(retry_after)) + 1)
        # The other case is when it timeout. We try once more just in case.
        try
            obj.client.Query(GITHUB_API_QUERY, operationName = operationName, vars = vars)
        catch err
            return err
        end
    end
    update!(obj)
    if isa(result, Exception)
        println(result)
    end
    result
end
"""
    restful(obj::GitHubPersonalAccessToken,
            endpoint::AbstractString;
            method::AbstractString = "GET",
            params::Dict{String} = Dict{String,String}(),
    )

Return response.
"""
function restful(
    obj::GitHubPersonalAccessToken,
    endpoint::AbstractString;
    method::AbstractString = "GET",
    params::Dict{String} = Dict{String,String}(),
  )
    update!(obj)
    if iszero(obj.limits.core.remaining)
        w = obj.limits.core.reset - now(utc_tz)
        sleep(max(w, zero(w)))
        obj.limits.core.remaining = obj.limits.core.limit
    end
    response = request(
      method,
      "$GITHUB_REST_ENDPOINT/$endpoint",
      [
        "Accept" => "application/vnd.github.v3+json",
        "User-Agent" => obj.login,
        "Authorization" => "token $(obj.token)",
      ],
      JSON3.write(params),
      )
    update!(obj)
    response
end

# Postgres related
"""
    Opt(login::AbstractString,
        token::AbstractString;
        db_usr::AbstractString = "postgres",
        db_pwd::AbstractString = "postgres",
        host::AbstractString = "postgres",
        port::Integer = 5432,
        dbname::AbstractString = "postgres",
        schema::AbstractString = "postgres",
        role::AbstractString = "postgres"
        )::Opt

Structure for passing arguments to functions.

# Fields
- `conn::Connection`
- `schema::String`
- `role::String`
- `pat::GitHubPersonalAccessToken`

# Example
```julia-repl
julia> opt = Opt("Nosferican",
                 ENV["GITHUB_TOKEN"],
                 host = ENV["POSTGRES_HOST"],
                 port = parse(Int, ENV["POSTGRES_PORT"]));

```
"""
struct Opt
    conn::Connection
    schema::String
    role::String
    pat::GitHubPersonalAccessToken
    function Opt(
        login::AbstractString,
        token::AbstractString;
        db_usr::AbstractString = "postgres",
        db_pwd::AbstractString = "postgres",
        schema::AbstractString = "postgres",
        role::AbstractString = "postgres",
        host::AbstractString = "postgres",
        port::Integer = 5432,
        dbname::AbstractString = "postgres",
    )
        conn =
            Connection("host = $host port = $port dbname = $dbname user = $db_usr password = $db_pwd")
        pat = GitHubPersonalAccessToken(login, token)
        new(conn, schema, role, pat)
    end
end
summary(io::IO, obj::Opt) = println(io, "Options for functions")
function show(io::IO, obj::Opt)
    print(io, summary(obj))
    println(io, replace(replace(string(obj.conn), r"^" => "  "), r"\n[^$]" => "\n  "))
    println(io, "  Schema: $(obj.schema)")
    println(io, "  Role: $(obj.role)")
    print(io, replace(replace(string(obj.pat), r"^" => "  "), r"\n[^$]" => "\n  "))
end
