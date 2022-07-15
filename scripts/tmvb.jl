# Settings/selections:


using Orthography
ortho = simpleAscii()
using Kanones
knormal("Μῆνιν")

using CitableBase, CitableText
using CitableCorpus
corpusurl = "https://raw.githubusercontent.com/neelsmith/CitableCorpusAnalysis.jl/main/test/data/gettysburg/gettysburgcorpus.cex"
corpus = fromcex(corpusurl, CitableTextCorpus, UrlReader)

normalized = map(corpus) do rawpsg
	CitablePassage(rawpsg.urn, knormal(rawpsg.text))
end |> CitableTextCorpus

tkns = begin
	alltokens = tokenize(normalized, ortho)
	filter(alltokens) do t
		t[2] == LexicalToken()
	end
end



using CitableCorpusAnalysis
n_psgs = 20
tmc = begin
	selectedcorpus = n_psgs == 0 ? normalized : CitableTextCorpus(normalized.passages[1:n_psgs])
	tmcorpus(selectedcorpus, ortho)
end



using TopicModelsVB
n = 5
iters = 250
model = LDA(tmc, n)
train!(model, iter=iters)

terms_n = 15
showtopics(model, cols = n, terms_n)
