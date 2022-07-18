using Pkg
Pkg.add(url = "https://github.com/neelsmith/CitableCorpusAnalysis.jl")
using CitableText, CitableCorpus, CitableBase
using Kanones
using CitableCorpusAnalysis
using Orthography, PolytonicGreek

ortho = literaryGreek()
allpsgs = CitablePassage[]
using ProgressLogging
@progress for i in 1:24
    url = "https://raw.githubusercontent.com/neelsmith/eustathius/main/cex/bk$(i).cex"
    append!(allpsgs, fromcex(url, CitableTextCorpus, UrlReader).passages)
end
corpus 	= CitableTextCorpus(allpsgs)
normalized = map(corpus) do rawpsg
	CitablePassage(rawpsg.urn, knormal(rawpsg.text))
end |> CitableTextCorpus


#selectedcorpus = n_psgs == 0 ? normalized : CitableTextCorpus(normalized.passages[1:n_psgs])
# tmc =	tmcorpus(selectedcorpus, ortho)
tmc =	tmcorpus(normalized, ortho)

alltokens = tokenize(normalized, ortho)
tkns = filter(alltokens) do t
    t[2] == LexicalToken()
end
