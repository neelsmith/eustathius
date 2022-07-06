


using CitableBase, CitableText
using CitableCorpus
corpusurl = "https://raw.githubusercontent.com/neelsmith/CitableCorpusAnalysis.jl/main/test/data/gettysburg/gettysburgcorpus.cex"
corpus = fromcex(corpusurl, CitableTextCorpus, UrlReader)

using Orthography
ortho = simpleAscii()


using CitableCorpusAnalysis
tmc = tmcorpus(corpus, ortho)


using TopicModelsVB
n = 5
iters = 250
model = LDA(tmc, n)
train!(model, iter=iters)