using EzXML
using PolytonicGreek, Orthography
using SplitApplyCombine


function simpletext(n::EzXML.Node, accum = "")
	rslts = [accum]
	if n.type == EzXML.ELEMENT_NODE 
        if ! (n.name == "ref")
            children = nodes(n)
            if !(isempty(children))
                for c in children
                    childres =  simpletext(c, accum)
                    push!(rslts, childres)
                end
            end
        end
			
	elseif 	n.type == EzXML.TEXT_NODE
		tidier = n.content #cleanws(n.content )#
		if !isempty(tidier)
			push!(rslts, accum * tidier)
		end
				
    else
        throw(DomainError("Unrecognized node type for node $(n.type)"))
	end
	join(rslts,"")
end




teins = "http://www.tei-c.org/ns/1.0"

o = literaryGreek()
f = "xmlsrc/tlg4083.tlg001.eoic-ed2VALK-grc.xml"
docroot = read(bigf) |> parsexml |> root

lines = findall("//tei:l", docroot, ["tei" => teins])
textlines = map(l -> simpletext(l), lines)
alltext = join(textlines, "\n")




tkns = tokenize(alltext, o)
lex = filter(t -> t.tokencategory == LexicalToken(), tkns) 
lexstrs = map(lex) do t
    cleaner = t.text |> lowercase |> nfkc
    PolytonicGreek.flipaccent(cleaner, o)
end

grouped = group(lexstrs)

counts = Tuple{String, Int64}[]
for term in keys(grouped)
    count = length(grouped[term])
    push!(counts, (term, count))
end

sorted = sort(counts, by = pr -> pr[2], rev = true)

wordlist = map(pr -> pr[1], sorted)
open("vocablist-all.txt", "w") do io
    write(io, join(wordlist,"\n"))
end


countstrings = map(pr -> string(pr[1], " ", pr[2]), sorted)
open("termcounts-all.txt", "w") do io
    write(io, join(countstrings, "\n"))
end


# Verbal adjective ratio!
#=
julia> vadjs = filter(sorted) do pro
       endswith(pro[1], "τέον")
       end

julia> vadjcount = map(vadjs) do pr
       pr[2]
       end |> sum
2498

julia> vocabcount = map(sorted) do pr
       pr[2]
       end |> sum
989463

julia> vadjcount / vocabcount
0.00252460172841228

julia> vocabcount
989463

julia> vocabcount / 989
1000.4681496461072

julia> vadjcount / 989
2.525783619817998


=#