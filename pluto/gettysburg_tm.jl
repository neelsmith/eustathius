### A Pluto.jl notebook ###
# v0.19.9

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


	Pkg.add("TSne")
	using TSne
	
	Pkg.add("Plots")
	using Plots

	Pkg.add("Statistics")
	using Statistics

	Pkg.add("SplitApplyCombine")
	using SplitApplyCombine
	
	Pkg.add("PlutoUI")
	using PlutoUI

	md"""(*Unhide this cell to see or modify your Julia environment*) """
end

# ╔═╡ 8dca993e-5777-4f19-93e1-c4732c27c000
md"""
*Technical background: the `TopicModelsVB` module*: see the [documentation](https://github.com/ericproffitt/TopicModelsVB.jl)
"""

# ╔═╡ 550e7828-af29-471a-ac08-bb886c3cafbb
md"""
# Topic modeling the Gettysburg Address

Analyze the corpus of the [five extant versions of the Gettysburg Address]($(corpusurl)).  Each text is cited in 4 passages.
"""

# ╔═╡ d9ff019a-f51d-4354-9d11-9cd6fc7c7a1a
md"""
!!! note "Settings for model"
"""

# ╔═╡ a0441ab9-3238-45bd-9a60-db0311daa91a
md"""
*Algorithm*: $(@bind algo Select(["LDA" => "Latent Dirichlet Allocation", "fCTM" => "filtered correlated LDA"], default="LDA")) *Number of topics*: $(@bind n confirm(Slider(2:20, default=12, show_value = true))) 


*Iterations* $(@bind iters confirm(Slider(100:50:1000, default=200, show_value = true)))
"""

# ╔═╡ 4e9a2aeb-431d-4ddd-900e-fc4331a58a31
md"""
*Number of stop-word candidates to review* $(@bind top_n confirm(Slider(20:500, default = 25, show_value = true)))
"""

# ╔═╡ 16ee8ad5-e2e0-4cf4-8391-680006375453
md"""
*Any **unchecked** terms will be treated as stop words.  **Check** any terms to include in the topic model.*
"""

# ╔═╡ 19857007-7ca3-44cf-8de9-cd6640a0b0ed
md"""
!!! note "Results"

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

# ╔═╡ ac9f80bc-63dc-4982-a292-02afa28613ec
#showtitles(tmc,[1,5, 9, 13, 17])

# ╔═╡ b8792a49-ef39-40e0-ad31-2cd2b914c1bc
md"""
*Document index* $(@bind doc_idx Slider(1:20,show_value = true))
"""

# ╔═╡ 7d7cbbce-da6b-4f78-9ba9-41ebcbc16efb
#topicdist(model, doc_idx)

# ╔═╡ 4745008a-95ab-4258-a192-91cd0cd58de1
html"""
<br/><br/><br/><br/><br/>
<hr/>
<i>You can ignore content below here</i>
"""

# ╔═╡ 6c8f12d5-5abe-4a8d-899c-4cd0909032f6
md"""
!!! note "The lexicon"
"""

# ╔═╡ e3ee28c4-61e6-4cf2-8b1b-73eb0085a674
md"""
!!! note "Computing the model"
"""

# ╔═╡ 34b57390-ded2-4b36-a77a-9a8a88048b0c
rescale(A; dims=1) = (A .- mean(A, dims=dims)) ./ max.(std(A, dims=dims), eps())


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

# ╔═╡ cab1b3d2-8232-495a-a2cd-462c6ca48955
tkns = begin
	alltokens = tokenize(corpus, ortho)
	filter(alltokens) do t
		t[2] == LexicalToken()
	end
end

# ╔═╡ 9e72945a-60fb-41c7-beb6-1237503ce881
 sorted =  begin
 	
	lex = filter(tkns) do tpair
		tpair[2] == LexicalToken()
	end
 	termdict = map(lex) do t
       t[1].text |> lowercase
	end |> group
	counts = []
	for k in keys(termdict)
		push!(counts, (k, length(termdict[k])))
	end
	sort(counts, by = pr -> pr[2], rev = true)
 end

# ╔═╡ 4cec56be-4ddd-4996-ac42-ad474f4db387
begin
	most_freq = map(sorted[1:top_n]) do pr
		pr[1]
	end
	
	@bind keepers MultiCheckBox(most_freq)
end

# ╔═╡ fddbb0bf-e271-4d23-87a7-722dadc56dac
keepers

# ╔═╡ 0b7b1f70-e866-4fe1-a197-30ceb3d39699
stopwords = begin
	stopterms = map(sorted[1:top_n]) do termpair
		termpair[1]
	end
	finalstops = filter(stopterms) do stopterm
		! (stopterm in keepers)
	end
	finalstops
end

# ╔═╡ 793a5c02-28cc-43aa-a1ac-2e5ccf0b6f16
md"""
**Summary of settings**

*Computing models for **$(n) topics**, computed with up to **$(iters) iterations**, using **$(algo)** algorithm*. Filtering corpus with list of **$(length(stopwords))** stop words.
"""

# ╔═╡ 2c7c5b6d-696b-42c1-aed6-ddca004ba71b
# ╠═╡ show_logs = false
tmc = begin
	psglist = map(psg -> psg.urn, corpus)
    tkns2 = filter(tkns) do tpr
       ! (tpr[1].text in stopwords)
    end
	psgs2 = map(pr -> pr[1], tkns2)

	finalpsgs = []
	for psgurn in psglist
		matchingpsgs = filter(psgs2) do p
			collapsePassageBy(dropversion(p.urn), 1) == dropversion(psgurn)
		end
		append!(finalpsgs, matchingpsgs)
	end
	filteredcorpus = CitableTextCorpus(finalpsgs)
	#filteredpsgs = map(tkns2) do pr
    #   CitablePassage(collapsePassageBy(pr[1].urn,1), pr[1].text)
	#end

	
	tmcorpus(filteredcorpus, ortho)
end

# ╔═╡ b8039ca9-8078-44fc-8ef7-932a55c036f8
# ╠═╡ show_logs = false
model = begin
	if algo == "LDA"
		model = LDA(tmc, n)
		train!(model, iter=iters)
		model
	elseif algo == "fCTM"
		model = fCTM(tmc, n)
		train!(model, tol = 0, checkelbo = Inf)
		model
	else
		nothing
	end
end

# ╔═╡ 5ca62dc9-8903-4175-ad19-4bc5b263f4a9
begin
	rows = []
	hdrs = ["Topic"]
	for hidx in 1:terms_n
		push!(hdrs, "Term $(hidx)")
	end
	push!(rows, "| " * join(hdrs, " | " ) * " |")

	formatspec = [" --- "]
	for fidx in 1:terms_n
		push!(formatspec, " --- ")
	end
	push!(rows, "| " * join(formatspec, " | " ) * " |")
	
	for (r,row) in enumerate(model.topics)
		colvals = ["**Topic $r**"]
       	for c in 1:terms_n
			push!(colvals, model.corp.vocab[model.topics[r][c]])
		end
		push!(rows, "| " * join(colvals, " | ") * " |" )
    end
	join(rows, "\n") |> Markdown.parse
end

# ╔═╡ 2d21ff74-9eab-4566-a41e-a49907f1652c
# Normalize values for plotting
rescaled = rescale(model.beta, dims=1);

# ╔═╡ 329777a9-5a5a-491d-98f7-5b1cabf32445
reduced = tsne(transpose(rescaled))

# ╔═╡ 5393cdc3-f6eb-40a6-9054-160f649d3459
scatter(reduced[:,1], reduced[:,2])

# ╔═╡ Cell order:
# ╟─d6b5324e-fc7b-11ec-31b9-49b421a1a9b9
# ╟─8dca993e-5777-4f19-93e1-c4732c27c000
# ╟─550e7828-af29-471a-ac08-bb886c3cafbb
# ╟─d9ff019a-f51d-4354-9d11-9cd6fc7c7a1a
# ╟─a0441ab9-3238-45bd-9a60-db0311daa91a
# ╟─4e9a2aeb-431d-4ddd-900e-fc4331a58a31
# ╟─16ee8ad5-e2e0-4cf4-8391-680006375453
# ╟─4cec56be-4ddd-4996-ac42-ad474f4db387
# ╟─793a5c02-28cc-43aa-a1ac-2e5ccf0b6f16
# ╟─19857007-7ca3-44cf-8de9-cd6640a0b0ed
# ╟─b8039ca9-8078-44fc-8ef7-932a55c036f8
# ╟─ae15ed3b-e72a-445c-aba8-81c73ca15952
# ╟─946877bf-adc6-484a-91a8-b3844e6fd38a
# ╟─5ca62dc9-8903-4175-ad19-4bc5b263f4a9
# ╟─5393cdc3-f6eb-40a6-9054-160f649d3459
# ╟─591a6683-128a-4774-9be3-72d8b77ec254
# ╟─81cb7a24-fc9e-4af4-af09-5a45eb655da2
# ╟─ac9f80bc-63dc-4982-a292-02afa28613ec
# ╟─b8792a49-ef39-40e0-ad31-2cd2b914c1bc
# ╠═7d7cbbce-da6b-4f78-9ba9-41ebcbc16efb
# ╟─4745008a-95ab-4258-a192-91cd0cd58de1
# ╟─6c8f12d5-5abe-4a8d-899c-4cd0909032f6
# ╟─0b7b1f70-e866-4fe1-a197-30ceb3d39699
# ╟─9e72945a-60fb-41c7-beb6-1237503ce881
# ╠═fddbb0bf-e271-4d23-87a7-722dadc56dac
# ╟─e3ee28c4-61e6-4cf2-8b1b-73eb0085a674
# ╟─34b57390-ded2-4b36-a77a-9a8a88048b0c
# ╠═2d21ff74-9eab-4566-a41e-a49907f1652c
# ╠═329777a9-5a5a-491d-98f7-5b1cabf32445
# ╟─df489afb-b545-45f2-81c8-90b494ca4e5e
# ╟─cab1b3d2-8232-495a-a2cd-462c6ca48955
# ╟─2c7c5b6d-696b-42c1-aed6-ddca004ba71b
# ╟─1cd69094-b285-498e-bcd9-49a01a073180
# ╟─4369945b-57aa-445b-bfe4-1d76af7e49e1
# ╟─4e38d01c-4d41-4b94-a9a7-d2ef090b9804
