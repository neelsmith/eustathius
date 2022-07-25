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

# ╔═╡ ccbe499f-409b-4383-8e79-599a31d917d7
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.add(url="https://github.com/neelsmith/CitableCorpusAnalysis.jl")
	Pkg.add("TopicModelsVB")

	Pkg.add("SplitApplyCombine")

	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")
	Pkg.add("CitableBase")

	Pkg.add("Orthography")	
	Pkg.add("PolytonicGreek")
	
	using CitableCorpusAnalysis
	using TopicModelsVB

	using SplitApplyCombine

	using CitableBase, CitableText, CitableCorpus

	using Orthography, PolytonicGreek

	Pkg.add("PlutoUI")
	using PlutoUI
	
	md"""(*Unhide this cell to see or modify your Julia environment*) """
end

# ╔═╡ 7df5ee6f-4998-4856-8c36-5ffe29be9be1
md"""
*Notebook version*: **1.0.2**
"""

# ╔═╡ a54a1bb6-fd70-11ec-2886-cdc4fb2e0c98
md"""
# Topic modeling lemmata in Eustathius
"""

# ╔═╡ bb1989a8-d29b-4425-b0c2-79528ae421ff
md"""
Initial downloading and tokenizing the entire corpus is slow.

After that, creating a topic model is faster or slower depending on the number of comments you choose to model.
"""

# ╔═╡ a24725e3-182b-4517-97da-33920b4fde27
md"""
!!! note "Settings for model"
"""

# ╔═╡ 34b24086-6510-4915-a039-31685a4c00a1
md"""*Number of topics*: $(@bind n confirm(Slider(2:50, default=12, show_value = true))) *Iterations* $(@bind iters confirm(Slider(100:50:1000, default=200, show_value = true)))
"""

# ╔═╡ c67e13cc-e823-4052-a04c-6916e7649f0a
md"""
*Computing models for **$(n) topics**, computed with up to **$(iters) iterations**.*
"""

# ╔═╡ 1c306e50-ec4c-4201-ba25-e3c6d2f3a633
md"""!!! note "Size of corpus to model"
    Set a number of passages to model.
"""

# ╔═╡ ff168b8e-84b4-4b7d-9dfa-9ef48f89747d
md"""
!!! note "Results: LDA algorithm"
"""

# ╔═╡ 39a33cee-b384-4a5c-bfd6-1c66d3c27956
md"""## Topic definitions"""

# ╔═╡ 54d1fe06-1ce6-4235-b89e-cb9236b0406d
md"""
*Number of terms to show* $(@bind terms_n Slider(5:50, default=10, show_value = true))
"""

# ╔═╡ 2a7a5ebf-f933-4db8-88b9-adcd8c4a1b64
html"""
<br/><br/><br/><br/><br/>
<hr/>
<i>You can ignore content below here</i>
"""

# ╔═╡ 23b4c746-d640-4be8-84dc-503b3d081d1f
md"""

!!! note "Configuration and loading data"
"""

# ╔═╡ 65240de4-2af4-45ef-834c-df6bc21c9874
ortho  = literaryGreek()

# ╔═╡ 283c4b81-1a1a-4204-a992-201f898c3934
stopwords = readlines("stopwords.txt")

# ╔═╡ 97962f36-db0c-44e5-aa21-1590a98e4979
eusturl = "https://www.homermultitext.org/eustathius/lemmatext_ed.cex"

# ╔═╡ 0640bd11-7107-492e-8cfb-f629b6db2caf
corpus = fromcex(eusturl, CitableTextCorpus, UrlReader)

# ╔═╡ dbf8e673-a705-4dd0-a5ba-23e28a2065a9
md"""*Comments to include*: $(@bind n_psgs confirm(Slider(0:length(corpus.passages), default=10, show_value = true))) 
"""

# ╔═╡ 38165986-a1cc-4eeb-aa81-da270455972d
md"""
!!! note "Tokenize and filter tokens by stopwords"
"""

# ╔═╡ 9097c25a-c906-4dce-b805-83b10c4d3973
filtered = begin
	psgs =  CitablePassage[]
	for p in corpus.passages
		psg_words = split(p.text)
		elided = filter(psg_words) do wd
			! (wd in stopwords)
		end
		push!(psgs, CitablePassage(p.urn, join(elided, " ")))
	end
	psgs
end

# ╔═╡ 08028ea4-725e-4b74-8689-2613024f94d8
# ╠═╡ show_logs = false
tmc = begin
	selectedcorpus = n_psgs == 0 ? corpus : CitableTextCorpus(filtered[1:n_psgs])
	tmcorpus(selectedcorpus, ortho)
end

# ╔═╡ 02290f23-b89b-49f9-8096-99f40017f01a
begin
	model = LDA(tmc, n)
	train!(model, tol = 0, iter=iters, checkelbo = Inf)
	model
end

# ╔═╡ d430eb4b-c9df-4e5a-a9c1-5b426a01eabc
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

# ╔═╡ Cell order:
# ╟─ccbe499f-409b-4383-8e79-599a31d917d7
# ╟─7df5ee6f-4998-4856-8c36-5ffe29be9be1
# ╟─a54a1bb6-fd70-11ec-2886-cdc4fb2e0c98
# ╟─bb1989a8-d29b-4425-b0c2-79528ae421ff
# ╟─a24725e3-182b-4517-97da-33920b4fde27
# ╟─34b24086-6510-4915-a039-31685a4c00a1
# ╟─c67e13cc-e823-4052-a04c-6916e7649f0a
# ╟─1c306e50-ec4c-4201-ba25-e3c6d2f3a633
# ╟─dbf8e673-a705-4dd0-a5ba-23e28a2065a9
# ╟─ff168b8e-84b4-4b7d-9dfa-9ef48f89747d
# ╟─02290f23-b89b-49f9-8096-99f40017f01a
# ╟─39a33cee-b384-4a5c-bfd6-1c66d3c27956
# ╟─54d1fe06-1ce6-4235-b89e-cb9236b0406d
# ╟─d430eb4b-c9df-4e5a-a9c1-5b426a01eabc
# ╟─2a7a5ebf-f933-4db8-88b9-adcd8c4a1b64
# ╟─23b4c746-d640-4be8-84dc-503b3d081d1f
# ╟─65240de4-2af4-45ef-834c-df6bc21c9874
# ╠═283c4b81-1a1a-4204-a992-201f898c3934
# ╟─97962f36-db0c-44e5-aa21-1590a98e4979
# ╟─0640bd11-7107-492e-8cfb-f629b6db2caf
# ╟─38165986-a1cc-4eeb-aa81-da270455972d
# ╟─9097c25a-c906-4dce-b805-83b10c4d3973
# ╟─08028ea4-725e-4b74-8689-2613024f94d8
