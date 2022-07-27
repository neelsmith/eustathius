### A Pluto.jl notebook ###
# v0.19.10

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
	Pkg.activate(".")

	Pkg.add("CitableCorpus")
	Pkg.add("CitableText")
	Pkg.add("CitableBase")

	Pkg.add("Orthography")	
	Pkg.add("PolytonicGreek")

	Pkg.add("SplitApplyCombine")
	
	using CitableBase, CitableText, CitableCorpus

	using Orthography
	using PolytonicGreek

	using SplitApplyCombine
	
	Pkg.add("PlutoUI")
	using PlutoUI

	md"""(*Unhide this cell to see or modify your Julia environment*) """
end

# ╔═╡ 7df5ee6f-4998-4856-8c36-5ffe29be9be1
md"""
*Notebook version*: **1.0.0**
"""

# ╔═╡ a54a1bb6-fd70-11ec-2886-cdc4fb2e0c98
md"""
# Edit stop word list and save to local file
"""

# ╔═╡ a24725e3-182b-4517-97da-33920b4fde27
md"""
!!! note "Settings"
"""

# ╔═╡ 88c105d9-471d-48c7-9661-13503783ef8d
md"""
*Number of stop-word candidates to review* $(@bind top_n confirm(Slider(20:500, default = 100, show_value = true)))
"""

# ╔═╡ c1a7755b-c100-49ec-9a20-5b34ebe7a7f1
md"""
*Any **unchecked** terms will be treated as stop words.  **Check** any terms to include in the topic model.*
"""

# ╔═╡ 7ffe3ce9-1128-43a3-a97e-22a62901e741
md"""
*Use this button to save your list to* `stopwords.txt` $(@bind save Button("Save file"))
"""

# ╔═╡ ae80ab9b-b002-4a38-a4a4-cca9e3284460
md"""
!!! note "The list of selected stop words"
"""

# ╔═╡ 23b4c746-d640-4be8-84dc-503b3d081d1f
md"""

!!! note "Configuration and loading data"
"""

# ╔═╡ 3d4c98bc-bd83-48c7-9537-a98a5f851ac3
eusturl = "https://www.homermultitext.org/eustathius/lemmatext_ed.cex"

# ╔═╡ 65240de4-2af4-45ef-834c-df6bc21c9874
ortho  = literaryGreek()

# ╔═╡ 005fba72-a05f-4de0-996b-5187b6d992b2
corpus = begin
	dummy = fromcex(eusturl, CitableTextCorpus,UrlReader)
	CitableTextCorpus(dummy.passages[1:1])
end


# ╔═╡ 1b3b47cc-a64d-48c3-9ff1-7b1ea87239c6
tkns = tokenize(corpus, ortho)

# ╔═╡ 831ef9d5-e70b-4b06-a250-b7cba1b12337
 sorted =  begin
 	
	
 	termdict = map(tkns) do t
       t[1].text |> lowercase
	end |> group
	counts = []
	for k in keys(termdict)
		push!(counts, (k, length(termdict[k])))
	end
	sort(counts, by = pr -> pr[2], rev = true)
 end

# ╔═╡ 9d83f24b-b4bb-452c-8a77-72591a2edb83
begin
	most_freq = map(sorted[1:top_n]) do pr
		pr[1]
	end
	
	@bind keepers MultiCheckBox(most_freq)
end

# ╔═╡ a5d8aad0-15dd-4d50-8b58-15e604c6424f
stopwords = begin
	stopterms = map(sorted[1:top_n]) do termpair
		termpair[1]
	end
	finalstops = filter(stopterms) do stopterm
		! (stopterm in keepers)
	end
	finalstops
end

# ╔═╡ 41fbc026-cd17-4de3-9f65-cee781e6e718
begin
	save
	open("stopwords.txt","w") do io
		write(io, join(stopwords,"\n"))
	end
end

# ╔═╡ Cell order:
# ╟─ccbe499f-409b-4383-8e79-599a31d917d7
# ╟─7df5ee6f-4998-4856-8c36-5ffe29be9be1
# ╟─a54a1bb6-fd70-11ec-2886-cdc4fb2e0c98
# ╟─a24725e3-182b-4517-97da-33920b4fde27
# ╟─88c105d9-471d-48c7-9661-13503783ef8d
# ╟─c1a7755b-c100-49ec-9a20-5b34ebe7a7f1
# ╟─7ffe3ce9-1128-43a3-a97e-22a62901e741
# ╟─41fbc026-cd17-4de3-9f65-cee781e6e718
# ╟─9d83f24b-b4bb-452c-8a77-72591a2edb83
# ╟─ae80ab9b-b002-4a38-a4a4-cca9e3284460
# ╟─a5d8aad0-15dd-4d50-8b58-15e604c6424f
# ╟─831ef9d5-e70b-4b06-a250-b7cba1b12337
# ╟─23b4c746-d640-4be8-84dc-503b3d081d1f
# ╟─3d4c98bc-bd83-48c7-9537-a98a5f851ac3
# ╟─65240de4-2af4-45ef-834c-df6bc21c9874
# ╟─005fba72-a05f-4de0-996b-5187b6d992b2
# ╟─1b3b47cc-a64d-48c3-9ff1-7b1ea87239c6
