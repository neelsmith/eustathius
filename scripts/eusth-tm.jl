using Pkg
Pkg.add(url = "https://github.com/neelsmith/CitableCorpusAnalysis.jl")
Pkg.add(url = "https://github.com/neelsmith/Kanones.jl")
using CitableText, CitableCorpus, CitableBase
using Kanones
using CitableParserBuilder
using CitableCorpusAnalysis
using Orthography, PolytonicGreek
using Downloads
using ProgressLogging

ortho = literaryGreek()
allpsgs = CitablePassage[]
@progress for i in 1:24
    url = "https://raw.githubusercontent.com/neelsmith/eustathius/main/cex/bk$(i).cex"
    append!(allpsgs, fromcex(url, CitableTextCorpus, UrlReader).passages)
end
corpus 	= CitableTextCorpus(allpsgs)
normalized = map(corpus) do rawpsg
	CitablePassage(rawpsg.urn, knormal(rawpsg.text))
end |> CitableTextCorpus

lsjlemms = Kanones.lsjdict()
lsjxlemms =  Kanones.lsjxdict()
morphurl = "http://www.homermultitext.org/morphology/morphology-current.csv"
morphfile = Downloads.download(morphurl)

#morphfile = "/Users/neelsmith/Desktop/summer22/sandbox/morphology-nohdr.csv"
morphfile = "/Users/mid/Desktop/morphology-current-nohdr.csv"
parser = dfParser(morphfile)

alltokens = tokenize(normalized, ortho)
tkns = filter(alltokens) do t
    t[2] == LexicalToken()
end
corpvocab = map(tkns) do tknpr
    tknpr[1].text
end |> unique


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
for (i, tpair) in enumerate(tkns)
    urn = tpair[1].urn
    lemm = filter(pr -> pr[1] == tpair[1].text, lemmalabels)[1][2]
    if i % 100 == 0
        @info("labelling $(i) / $(length(tkns))")
    end
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


open("eusth-lemmatized.cex", "w") do io
    write(io, cex(lemmatizedcorp))
end









import Orthography: tokenize
import Orthography: codepoints
import Orthography: tokentypes

"An orthographic system for a basic alphabetic subset of the ASCII characater set."
struct WSTokenizer <: OrthographicSystem
end

OrthographyTrait(::Type{WSTokenizer}) = IsOrthographicSystem()

"""Implement tokentypes function for SimpleAscii.
"""
function tokentypes(ortho::WSTokenizer)
    [LexicalToken()]
end


"""Implement codepoints function for SimpleAscii.
"""
function codepoints(ortho::WSTokenizer)
    #ortho.codepoints
    []
end





#####################################
#=
tmc =  tmcorpus(lemmatizedcorp, orh)


using TopicModelsVB
n = 5
iters = 250
model = LDA(tmc, n)
train!(model, iter=iters)

terms_n = 15
showtopics(model, cols = n, terms_n)

=#