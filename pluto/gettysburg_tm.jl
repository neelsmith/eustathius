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

# ╔═╡ d6b5324e-fc7b-11ec-31b9-49b421a1a9b9
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
	
	Pkg.add("PlutoUI")
	using PlutoUI

	md"""(*Unhide this cell to see or modify your Julia environment*) """
end

# ╔═╡ 550e7828-af29-471a-ac08-bb886c3cafbb
md"""
# Topic modeling the Gettysburg Address

Analyze the corpus of the [five extant versions of the Gettysburg Address]($(corpusurl)).  Each text is cited in 4 passages.
"""

# ╔═╡ 8dca993e-5777-4f19-93e1-c4732c27c000
md"""
## The `TopicModelsVB` module

See the [documentation](https://github.com/ericproffitt/TopicModelsVB.jl)
"""

# ╔═╡ 1db8ff3b-a0d8-4c35-b76c-fef53c444c25
md"""*Number of topics*: $(@bind n confirm(Slider(2:20, default=5, show_value = true))) *Iterations* $(@bind iters confirm(Slider(100:50:1000, default=200, show_value = true)))
"""

# ╔═╡ 793a5c02-28cc-43aa-a1ac-2e5ccf0b6f16
md"""
Computing LDA model for **$(n) topics**, computed with up to **$(iters) iterations**
"""

# ╔═╡ 836a2093-fdeb-4aea-9c8a-c1d48fd76565
md"""
## Results
"""

# ╔═╡ ae15ed3b-e72a-445c-aba8-81c73ca15952
md"""### Topic definitions"""

# ╔═╡ 946877bf-adc6-484a-91a8-b3844e6fd38a
md"""
*Number of terms to show* $(@bind terms_n Slider(5:50, default=10, show_value = true))
"""

# ╔═╡ 591a6683-128a-4774-9be3-72d8b77ec254
md"""
### Exploring documents
"""

# ╔═╡ 81cb7a24-fc9e-4af4-af09-5a45eb655da2
md"""
URNs for first "document" in each citable group
"""

# ╔═╡ b8792a49-ef39-40e0-ad31-2cd2b914c1bc
md"""
*Document index* $(@bind doc_idx Slider(1:20,show_value = true))
"""

# ╔═╡ 4745008a-95ab-4258-a192-91cd0cd58de1
html"""
<br/><br/><br/><br/><br/>
<hr/>
<i>You can ignore content below here</i>
"""

# ╔═╡ e3ee28c4-61e6-4cf2-8b1b-73eb0085a674
md"""
!!! note "Computing the model"
"""

# ╔═╡ df489afb-b545-45f2-81c8-90b494ca4e5e
md"""

!!! note "Configuration and loading data"
"""

# ╔═╡ 1cd69094-b285-498e-bcd9-49a01a073180
corpusurl = "https://raw.githubusercontent.com/neelsmith/CitableCorpusAnalysis.jl/main/test/data/gettysburg/gettysburgcorpus.cex"

# ╔═╡ 4369945b-57aa-445b-bfe4-1d76af7e49e1
corpus = fromcex(corpusurl, CitableTextCorpus, UrlReader)

# ╔═╡ 4e38d01c-4d41-4b94-a9a7-d2ef090b9804
ortho = simpleAscii()

# ╔═╡ 2c7c5b6d-696b-42c1-aed6-ddca004ba71b
# ╠═╡ show_logs = false
tmc = tmcorpus(corpus, ortho)

# ╔═╡ b8039ca9-8078-44fc-8ef7-932a55c036f8
# ╠═╡ show_logs = false
begin
	model = LDA(tmc, n)
	train!(model, iter=iters)
	model
end

# ╔═╡ 81fbe20a-75e4-4c20-8aab-aabe20f0e224
showtopics(model, cols = n, terms_n)

# ╔═╡ 1f789e6a-411b-4943-8e67-6661799ae167
model.beta

# ╔═╡ 7d7cbbce-da6b-4f78-9ba9-41ebcbc16efb
topicdist(model, doc_idx)

# ╔═╡ ac9f80bc-63dc-4982-a292-02afa28613ec
showtitles(tmc,[1,5, 9, 13, 17])

# ╔═╡ Cell order:
# ╟─d6b5324e-fc7b-11ec-31b9-49b421a1a9b9
# ╟─550e7828-af29-471a-ac08-bb886c3cafbb
# ╟─8dca993e-5777-4f19-93e1-c4732c27c000
# ╟─1db8ff3b-a0d8-4c35-b76c-fef53c444c25
# ╟─793a5c02-28cc-43aa-a1ac-2e5ccf0b6f16
# ╟─836a2093-fdeb-4aea-9c8a-c1d48fd76565
# ╟─b8039ca9-8078-44fc-8ef7-932a55c036f8
# ╟─ae15ed3b-e72a-445c-aba8-81c73ca15952
# ╠═946877bf-adc6-484a-91a8-b3844e6fd38a
# ╟─81fbe20a-75e4-4c20-8aab-aabe20f0e224
# ╟─1f789e6a-411b-4943-8e67-6661799ae167
# ╟─591a6683-128a-4774-9be3-72d8b77ec254
# ╟─81cb7a24-fc9e-4af4-af09-5a45eb655da2
# ╟─ac9f80bc-63dc-4982-a292-02afa28613ec
# ╟─b8792a49-ef39-40e0-ad31-2cd2b914c1bc
# ╟─7d7cbbce-da6b-4f78-9ba9-41ebcbc16efb
# ╟─4745008a-95ab-4258-a192-91cd0cd58de1
# ╟─e3ee28c4-61e6-4cf2-8b1b-73eb0085a674
# ╟─df489afb-b545-45f2-81c8-90b494ca4e5e
# ╟─2c7c5b6d-696b-42c1-aed6-ddca004ba71b
# ╟─1cd69094-b285-498e-bcd9-49a01a073180
# ╟─4369945b-57aa-445b-bfe4-1d76af7e49e1
# ╟─4e38d01c-4d41-4b94-a9a7-d2ef090b9804
