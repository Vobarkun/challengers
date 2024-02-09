struct CardPile
    drawpiles::Dict{Tier,Vector{Card}}
    returnpiles::Dict{Tier,Vector{Card}}
end

function CardPile() 
    CardPile(
        Dict(A => shuffle!(makepile(Acards)), B => shuffle!(makepile(Bcards)), C => shuffle!(makepile(Ccards))), 
        Dict(A => Card[], B => Card[], C => Card[])
    )
end

function draw!(pile::CardPile, tier)
    dpile = pile.drawpiles[tier]; rpile = pile.returnpiles[tier]
    if isempty(dpile)
        append!(dpile, rpile)
        shuffle!(dpile)
        empty!(rpile)
    end
    pop!(dpile)
end

function draw!(to, pile::CardPile, tier::Tier, n)
    for i in 1:n
        push!(to, draw!(pile, tier))
    end
    to
end

function draw(pile::CardPile, tier::Tier, n)
    draw!(Card[], pile, tier, n)
end

function ret!(pile::CardPile, card::Card)
    (card.tier == S || card.tier == notier) && return pile
    push!(pile.returnpiles[card.tier], card)
end

function ret!(pile::CardPile, cards)
    for c in cards ret!(pile, c) end
end