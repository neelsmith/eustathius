### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ccbe499f-409b-4383-8e79-599a31d917d7
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.add(url="https://github.com/neelsmith/CitableCorpusAnalysis.jl")
	using CitableCorpusAnalysis

	Pkg.add("TopicModelsVB")
	using TopicModelsVB

	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")
	Pkg.add("CitableBase")
	using CitableBase, CitableText, CitableCorpus

	Pkg.add("Orthography")	
	using Orthography

	Pkg.add("PolytonicGreek")
	using PolytonicGreek


	Pkg.add("TSne")
	using TSne
	
	Pkg.add("Plots")
	using Plots

	Pkg.add("Statistics")
	using Statistics
	
	Pkg.add("PlutoUI")
	using PlutoUI

	md"""(*Unhide this cell to see or modify your Julia environment*) """
end

# ╔═╡ a54a1bb6-fd70-11ec-2886-cdc4fb2e0c98
md"""
# Topic modeling tokens in Eustathius
"""

# ╔═╡ a24725e3-182b-4517-97da-33920b4fde27
md"""
!!! note "Settings for model"
"""

# ╔═╡ 34b24086-6510-4915-a039-31685a4c00a1
md"""*Number of topics*: $(@bind n confirm(Slider(2:20, default=12, show_value = true))) *Iterations* $(@bind iters confirm(Slider(100:50:1000, default=200, show_value = true)))
"""

# ╔═╡ c67e13cc-e823-4052-a04c-6916e7649f0a
md"""
*Computing models for **$(n) topics**, computed with up to **$(iters) iterations**.*
"""

# ╔═╡ ff168b8e-84b4-4b7d-9dfa-9ef48f89747d
md"""
!!! note "Results: fCTM algorithm"
"""

# ╔═╡ 39a33cee-b384-4a5c-bfd6-1c66d3c27956
md"""## Topic definitions"""

# ╔═╡ 54d1fe06-1ce6-4235-b89e-cb9236b0406d
md"""
*Number of terms to show* $(@bind terms_n Slider(5:50, default=10, show_value = true))
"""

# ╔═╡ 23b4c746-d640-4be8-84dc-503b3d081d1f
md"""

!!! note "Configuration and loading data"
"""

# ╔═╡ 48b10dd6-f1c8-424e-acfd-b67292620977
url = "https://raw.githubusercontent.com/neelsmith/eustathius/main/cex/bk21.cex"

# ╔═╡ 005fba72-a05f-4de0-996b-5187b6d992b2
corpus = fromcex(url, CitableTextCorpus, UrlReader)

# ╔═╡ 65240de4-2af4-45ef-834c-df6bc21c9874
ortho  = literaryGreek()

# ╔═╡ 08028ea4-725e-4b74-8689-2613024f94d8
# ╠═╡ show_logs = false
tmc = tmcorpus(corpus, ortho)

# ╔═╡ 02290f23-b89b-49f9-8096-99f40017f01a
begin
	ctm_model = fCTM(tmc, n)
	train!(ctm_model, tol = 0, checkelbo = Inf)
	ctm_model
end

# ╔═╡ 6cb689f8-d5da-4d1d-86dd-99a55264672a
showtopics(ctm_model, cols = n, terms_n)

# ╔═╡ 93e85656-ff97-44b2-b93e-8e6aef044d46
md"""

!!! note "Computing results"
"""

# ╔═╡ 05198d19-b82c-4b79-ba5d-676adf4958fa
rescale(A; dims=1) = (A .- mean(A, dims=dims)) ./ max.(std(A, dims=dims), eps())

# ╔═╡ 92166f58-0ce5-4434-9567-7a3e8375570a
rescaled = rescale(ctm_model.beta, dims=1);

# ╔═╡ e2be100d-debe-4d34-95d6-2e9c18b34193
# ╠═╡ show_logs = false
reduced = tsne(transpose(rescaled))

# ╔═╡ df4681eb-ce41-4676-b54d-c88ae23ab680
scatter(reduced[:,1], reduced[:,2])

# ╔═╡ Cell order:
# ╟─ccbe499f-409b-4383-8e79-599a31d917d7
# ╟─a54a1bb6-fd70-11ec-2886-cdc4fb2e0c98
# ╟─a24725e3-182b-4517-97da-33920b4fde27
# ╟─34b24086-6510-4915-a039-31685a4c00a1
# ╟─c67e13cc-e823-4052-a04c-6916e7649f0a
# ╟─ff168b8e-84b4-4b7d-9dfa-9ef48f89747d
# ╟─02290f23-b89b-49f9-8096-99f40017f01a
# ╟─39a33cee-b384-4a5c-bfd6-1c66d3c27956
# ╟─54d1fe06-1ce6-4235-b89e-cb9236b0406d
# ╟─6cb689f8-d5da-4d1d-86dd-99a55264672a
# ╠═df4681eb-ce41-4676-b54d-c88ae23ab680
# ╟─23b4c746-d640-4be8-84dc-503b3d081d1f
# ╟─08028ea4-725e-4b74-8689-2613024f94d8
# ╟─48b10dd6-f1c8-424e-acfd-b67292620977
# ╟─005fba72-a05f-4de0-996b-5187b6d992b2
# ╟─65240de4-2af4-45ef-834c-df6bc21c9874
# ╟─93e85656-ff97-44b2-b93e-8e6aef044d46
# ╟─05198d19-b82c-4b79-ba5d-676adf4958fa
# ╠═92166f58-0ce5-4434-9567-7a3e8375570a
# ╠═e2be100d-debe-4d34-95d6-2e9c18b34193
