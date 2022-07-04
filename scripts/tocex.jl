using EzXML
using PolytonicGreek, Orthography
using CitableText, CitableCorpus


o = literaryGreek()

"""Skip `ref` elements.
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
	catted = join(rslts,"")
    replace(catted, "\n" => " ") |> strip
end



function bookcex(nodelist, bk = 21)
    urnbase = "urn:cts:greekLit:tlg4083.tlg001.hc:$(bk)."

    cexlines = []
    for (i, comment) in enumerate(nodelist)
        u =CtsUrn("$(urnbase)$(i)")
        txt = simpletext(comment)
        push!(cexlines, "$(u)|$(txt)")
    end
    join(cexlines,"\n")
end




f = "books/bk21.xml"
greektext = read(f) |> parsexml |> root
bk21comments = findall("//comment", greektext)
cex = bookcex(bk21comments)
outfile = "cex/bk21.cex"
open(outfile,"w") do io
    write(io, "#!ctsdata\n" * cex)
end


