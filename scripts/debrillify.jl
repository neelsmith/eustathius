using EzXML
using PolytonicGreek, Orthography
using CitableText, CitableCorpus

#bknum = 1
o = literaryGreek()


function stripmilestone(s)
    msre = r"<milestone.+/>"
    replace(s, msre => "")
end

"""TEI div, p and l are all bogus. Kill 'em.
"""
function stripfakehierarchy(s)
    divre = r"<div[^>]*>"
    nodivopens = replace(s, divre => "")
    nodivs = replace(nodivopens, "</div>" => "")
    noparas = replace(nodivs, r"</?p>" => "")
    nolineopen = replace(noparas, r"<l[^>]+>" => "")
    nolines = replace(nolineopen, "</l>" => "")
    #replace(nolines, r"\s*\|\s*" => "")
    replace(nolines, "|" => "")
end 

function fixorth(s)
    nohyphens = replace(s, r"–$\n[\s]*"m => "")
    ems = replace(nohyphens, "—" => " — ")
    highstops = replace(ems, "·" => ":")
    
end

"""Remove metadata from Brill: quotation marks, brackets."""
function tokensafe(s)
    replace(s, r"[«»\[\]]" => "")
end

function debrillify(s, n )
    no_ms = stripmilestone(s)
    nohardcopyjunk = stripfakehierarchy(no_ms)
    orthofied = fixorth(nohardcopyjunk)
    titled = replace(orthofied, "head" => "title")
    citeopen = replace(titled, r"<ref><hi rend=\"bold\">\(v.[\s]*" => "</comment>\n\n<comment>\n<ref>$(n).")
    cited = replace(citeopen, ")</hi></ref>" => "</ref>")

    opener = replace(cited, "</title>" => "</title>\n<comment>")
    closer = replace(opener, "</book>" => "</comment>\n\n</book>")

    wawre = r"<hi rend=\"overline\">([^>]+)</hi>"
    waw = replace(closer, wawre => s"<rs type=\"waw\">\1</rs> ")
    tidierws = replace(waw, r"[\t ]+" => " ")
    tokensafe(tidierws)
end



function writebook(n)
    f = "xmlbybook/bk$(n).xml"
    raw = read(f) |> String
    @info("Debrillifying book $(n)...")
    debrillified = debrillify(raw, n)
    outfile = "debrillified/bk$(n).xml"
    open(outfile,"w") do io
        write(io, debrillified)
    end
end

for i in 1:24
    @info("Writing book $(i)")
    writebook(i)
end