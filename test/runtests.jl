using Test, Documenter, COVID_Tracking_Clean

@testset "Dry Run" begin
    @test COVID_Tracking_Clean.main(false)
end

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
