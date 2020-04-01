using Test, Documenter, COVID_Tracking_Clean

ENV["POSTGIS_HOST"] = get(ENV, "POSTGIS_HOST", "host.docker.internal")
ENV["POSTGIS_PORT"] = get(ENV, "POSTGIS_PORT", "5432")
ENV["GITHUB_TOKEN"] = get(ENV, "GITHUB_TOKEN", "")

@testset "Documentation" begin
    using Documenter, COVID_Tracking_Clean

    DocMeta.setdocmeta!(COVID_Tracking_Clean,
                        :DocTestSetup,
                        :(using COVID_Tracking_Clean;),
                        recursive = true)
    makedocs(sitename = "COVID_Tracking_Clean",
             modules = [COVID_Tracking_Clean],
             pages = [
                 "Home" => "index.md",
                 "API" => "api.md"
             ],
             source = joinpath("..", "docs", "src"),
             build = joinpath("..", "docs", "build"),
             )
    @test true
end
