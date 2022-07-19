using Pkg
Pkg.add(url = "https://github.com/neelsmith/CitableCorpusAnalysis.jl")
Pkg.add(url = "https://github.com/neelsmith/Kanones.jl")
using CitableText, CitableCorpus, CitableBase
using Kanones
using CitableCorpusAnalysis
using Orthography, PolytonicGreek
using Downloads

ortho = literaryGreek()
allpsgs = CitablePassage[]
using ProgressLogging
@progress for i in 1:2 #1:24
    url = "https://raw.githubusercontent.com/neelsmith/eustathius/main/cex/bk$(i).cex"
    append!(allpsgs, fromcex(url, CitableTextCorpus, UrlReader).passages)
end
corpus 	= CitableTextCorpus(allpsgs)
normalized = map(corpus) do rawpsg
	CitablePassage(rawpsg.urn, knormal(rawpsg.text))
end |> CitableTextCorpus

#morphurl = "http://www.homermultitext.org/morphology/morphology-current.csv"
# morphfile = Downloads.download(morphurl)

morphfile = "/Users/neelsmith/Desktop/summer22/sandbox/morphology-nohdr.csv"
parser = dfParser(morphfile)

acorp = AnalyticalCorpus(normalized, ortho, parser)
#vocab = vocabulary(acorp)


alltokens = tokenize(normalized, ortho)
tkns = filter(alltokens) do t
    t[2] == LexicalToken()
end
corpvocab = map(tkns) do tknpr
    tknpr[1].text
end |> unique


lemmadict = Dict()
for (i, wd) in enumerate(corpvocab)
    if (i % 100) == 0
        @info("Parsing token $(i) / $(length(vocab))")
    end
    parses = parsetoken(wd, parser)
    lexemes = map(p -> p.lexeme, parses)
    lemmadict[wd] = unique(lexemes)
end




#selectedcorpus = n_psgs == 0 ? normalized : CitableTextCorpus(normalized.passages[1:n_psgs])
# tmc =	tmcorpus(selectedcorpus, ortho)
#tmc =	tmcorpus(normalized, ortho)

