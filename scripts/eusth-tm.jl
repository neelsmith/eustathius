using Pkg
Pkg.add(url = "https://github.com/neelsmith/CitableCorpusAnalysis.jl")
Pkg.add(url = "https://github.com/neelsmith/Kanones.jl")
using CitableText, CitableCorpus, CitableBase
using Kanones, CitableParserBuilder
using CitableCorpusAnalysis
using Orthography, PolytonicGreek
using Downloads

ortho = literaryGreek()
allpsgs = CitablePassage[]
using ProgressLogging
@progress for i in 21:21 #1:24
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

# acorp = AnalyticalCorpus(normalized, ortho, parser)
#vocab = vocabulary(acorp)


alltokens = tokenize(normalized, ortho)
tkns = filter(alltokens) do t
    t[2] == LexicalToken()
end
corpvocab = map(tkns) do tknpr
    tknpr[1].text
end |> unique


lsjlemms = Kanones.lsjdict()
lsjxlemms =  Kanones.lsjxdict()
lemmatized = []
for (i, wd) in enumerate(corpvocab)
    if (i % 100) == 0
        @info("Parsing token $(i) / $(length(corpvocab))")
    end
    parses = parsetoken(wd, parser)
    lexemes = map(p -> p.lexeme, parses)
    lexids = map(unique(lexemes)) do lex
        idval = CitableParserBuilder.objectid(lex)
        if haskey(lsjlemms, string(idval))
            string(lsjlemms[string(idval)], "_", idval)
        elseif haskey(lsjxlemms, string(idval))
            string(lsjxlemms[string(idval)], "_", idval)
        else
            string(lex)
        end
    end
    push!(lemmatized, (wd, lexids))
end



lemmalabels = map(lemmatized) do pr
    lemmstrings = join(map(u -> string(u), pr[2]), "+") 
    lemmlabel = if isempty(lemmstrings) 
        string(pr[1],"_none") 
    else
         lemmstrings
    end
    (pr[1], lemmlabel)
end

concordance = corpusindex(normalized, ortho)
tokencounts = []
for k in keys(concordance)
    push!(tokencounts, (k, length(concordance[k])))
end


lemmacountdict = Dict()
for (term,count) in tokencounts
    entry = filter(pr ->  pr[1] == term, lemmalabels)[1][2]
    if haskey(lemmacounts, entry)
        lemmacountdict[entry] =  lemmacounts[entry] + count
    else
        lemmacountdict[entry] = count
    end
end

lemmacounts = []
for k in keys(lemmacountdict)
    push!(lemmacounts, (k, lemmacountdict[k]))
end
sort!(lemmacounts, by = pr -> pr[2], rev = true)



lemm_passages  = []
for tpair in tkns
    urn = tpair[1].urn
    lemm = filter(pr -> pr[1] == tpair[1].text, lemmalabels)[1][2]
    println(lemm, " -- ", urn)
    push!(lemm_passages, CitablePassage(urn, lemm))
end 
lemm_edition = CitableTextCorpus(lemm_passages)

canonicalreff = map(p -> collapsePassageBy(p.urn,1), lemm_edition.passages) |> unique

lemmatizedcanon = CitablePassage[]
for ref in canonicalreff
    psglemms = filter(p -> ref  == collapsePassageBy(p.urn,1), lemm_edition.passages) 
    txtvals = map(p -> p.text, psglemms)
    push!(lemmatizedcanon, CitablePassage(ref, join(txtvals, " ")))
end

lemmatizedcorp = CitableTextCorpus(lemmatizedcanon)
#selectedcorpus = n_psgs == 0 ? normalized : CitableTextCorpus(normalized.passages[1:n_psgs])
# tmc =	tmcorpus(selectedcorpus, ortho)
#tmc =	tmcorpus(normalized, ortho)

