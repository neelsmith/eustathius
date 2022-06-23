using EzXML
using PolytonicGreek, Orthography
using SplitApplyCombine

"""Skip `ref` elements
$(SIGNATURES)
"""
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


o = literaryGreek()
f = "books/bk21.xml"
greektext = read(f) |> parsexml |> root  |> simpletext

tkns = tokenize(greektext, o)
lex = filter(t -> t.tokencategory == LexicalToken(), tkns) 
lexstrs = map(lex) do t
    t.text |> lowercase |> nfkc
end

grouped = group(lexstrs)

counts = Tuple{String, Int64}[]
for term in keys(grouped)
    count = length(grouped[term])
    push!(counts, (term, count))
end

sorted = sort(counts, by = pr -> pr[2], rev = true)