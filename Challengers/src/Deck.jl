mutable struct Deck
    nunique::Int
    cards::Vector{Card}
    values::Vector{Int}
    fixed::Vector{Bool}
end

function Deck(cards)
    values = [power(c) * sum(isequal(c.name) ∘ name, cards) for c in cards]
    deck = Deck(length(unique(cards)), cards, values, fill(false, length(cards)))
    perm = sortperm(deck.values)
    deck.values .= deck.values[perm]
    deck.cards .= deck.cards[perm]
    deck.fixed .= deck.fixed[perm]
    deck
end

Deck() = Deck(0, Card[], Int[], Bool[]);

function Base.push!(deck::Deck, card; fix = false)
    ind = findfirst(isequal(card.id) ∘ id, deck.cards)
    if isnothing(ind)
        deck.nunique += 1
        ind = length(deck) + 1
    end
    insert!(deck.cards, ind, card)
    insert!(deck.values, ind, card.power)
    insert!(deck.fixed, ind, fix)

    inds = findfirst(isequal(card.id) ∘ id, deck.cards) : findlast(isequal(card.id) ∘ id, deck.cards)
    deck.values[inds] .= card.power * length(inds) + 4any(deck.fixed[inds])

    perm = sortperm(deck.values)
    deck.values .= deck.values[perm]
    deck.cards .= deck.cards[perm]
    deck.fixed .= deck.fixed[perm]

    deck
end

Base.getindex(deck::Deck, i) = deck.cards[i]
Base.length(deck::Deck) = length(deck.cards)
Base.iterate(deck::Deck, state = 1) = state > length(deck) ? nothing : (deck.cards[state], state + 1)
Base.copy(deck::Deck) = Deck(deck.nunique, copy(deck.cards), copy(deck.values), copy(deck.fixed))
Base.isempty(deck::Deck) = isempty(deck.cards)

function Base.copy!(d1::Deck, d2::Deck)
    d1.nunique = d2.nunique
    copy!(d1.cards, d2.cards)
    copy!(d1.values, d2.values)
    copy!(d1.fixed, d2.fixed)
end

function Base.popfirst!(deck::Deck)
    c = popfirst!(deck.cards)
    popfirst!(deck.values)
    popfirst!(deck.fixed)
    if !isempty(deck) && c.name != deck[1].name
        deck.nunique -= 1
    end
    c
end

function remove!(deck::Deck, card)
    ind = findfirst(isequal(card), deck.cards)
    if !isnothing(ind)
        deleteat!(deck.cards, ind)
        deleteat!(deck.values, ind)
        deleteat!(deck.fixed, ind)
        if any(isequal(card.id) ∘ id, deck.cards)
            inds = findfirst(isequal(card.id) ∘ id, deck.cards) : findlast(isequal(card.id) ∘ id, deck.cards)
            deck.values[inds] .= card.power * length(inds) + 100any(deck.fixed[inds])
        end
    end
end

function optimize!(deck::Deck; nsamples = 10, state = nothing)
    state = isnothing(state) ? State() : state
    opponent = Card[]

    strength = 0.0
    imax = 0
    for i in 1:length(deck)
        if i > 1 && deck[i-1].id == deck[i].id
            continue
        end
        nstrength = mean(1:nsamples) do k
            reset!(state, view(deck.cards, i:length(deck)), opponent)
            shuffle!(state.deck[1])
            calculateStrength!(state)
        end
        if nstrength > strength
            strength = nstrength
            imax = i
        elseif nstrength < strength - 10
            break
        end
    end
    discarded = Card[]
    for _ in 1:imax-1
        push!(discarded, popfirst!(deck))
    end
    strength, discarded
end

function pickCard!(deck, newcards, pile = nothing, state = nothing)
    newdecks = map(newcards) do cs
        newdeck = copy(deck)
        for c in (cs isa Card ? tuple(cs) : cs) 
            push!(newdeck, c) 
        end
        strength, discarded = optimize!(newdeck, nsamples = 5, state = state)
        (strength, discarded, newdeck)
    end
    best = argmax(first.(newdecks))
    copy!(deck, last(newdecks[best]))
    ret!(pile, newdecks[best][2])
    newcards[best]
end

function pickCards!(deck, pile::CardPile, tier, ncards = 1; state = nothing)
    ncards == 0 && return
    if ncards == 1
        cards = draw(pile, tier, 5)
        picked = pickCard!(deck, cards, pile)
        ind = findfirst(isequal(picked), cards)
        for i in eachindex(cards)
            if i != ind
                ret!(pile, cards[i])
            end
        end
    elseif ncards == 2
        cards1 = draw(pile, tier, 5)
        cards2 = draw(pile, tier, 5)
        picked = pickCard!(deck, tuple.(cards1, reshape(cards2, 1, :)), pile)
        for (p, cards) in zip(picked, (cards1, cards2))
            ind = findfirst(isequal(p), cards)
            for i in eachindex(cards)
                if i != ind
                    ret!(pile, cards[i])
                end
            end
        end
    end
    return
end

function makeDeck(cards...; fixcards = true)
    pile = CardPile()
    deck = Deck()
    for scard in makepile(Scards)
        push!(deck, scard, fix = fixcards && in(scard, cards))
    end
    for (tier, npicks) in zip((ch.A, ch.B, ch.C), (6, 5, 3))
        for c in cards
            if c.tier == tier
                push!(deck, c, fix = fixcards)
                npicks -= 1
            end
        end
        if isodd(npicks)
            pickCard!(deck, draw(pile, tier, 5))
            npicks -= 1
        end
        for i in 1 : npicks ÷ 2
            pickCard!(deck, tuple.(draw(pile, tier, 5), reshape(draw(pile, tier, 5), 1, :)))
        end
    end
    optimize!(deck, nsamples = 50)
    deck
end

function Base.show(io::IO, m::MIME"text/plain", d::Deck)
    print(io, "Deck(nunique = ")
    show(io, d.nunique); print(io, ", ")
    show(io, typeof(d.cards)); print(io, "): ")
    for c in d.cards
        println(io); print(io, " ")
        show(io, c)
    end
end

mutable struct Player
    deck::Deck
    fans::Int
    trophies::Vector{Int}
end

Player(deck::Deck; fans = 0, trophies = Int[]) = Player(deck, fans, trophies)
Player(cards::Vector{Card}; kwargs...) = Player(Deck(cards); kwargs...)
Player(; kwargs...) = Player(Deck(makepile(Scards)); kwargs...)

function play!(players, round::Int; state = nothing)
    state = isnothing(state) ? State() : state
    reset!(state, players[1].deck, players[2].deck)
    shuffle!(state.deck[1]); shuffle!(state.deck[2])

    lasttrophies = map(p -> maximum(p.trophies, init = 0), players)
    state.toplay = (lasttrophies[1] == lasttrophies[2] ? rand(Bool) : lasttrophies[1] > lasttrophies[2])
    for i in 1:2 state.ntrophies[i] = length(players[i].trophies) end

    result = simulate!(state)

    for i in 1:2
        players[i].fans += result.gainedFans[i]
        for c in result.gainedCards[i]
            push!(players[i].deck, c)
        end
        for c in result.lostCards[i]
            remove!(players[i].deck, c)
        end
    end
    push!(players[result.winner].trophies, round)

    result
end

play!(player1, player2, round::Int; kwargs...) = play!((player1, player2), round; kwargs...)

function Base.show(io::IO, m::MIME"text/plain", p::Player)
    print(io, "Player(fans = ")
    show(io, p.fans); print(io, ", trophies = ")
    show(io, p.trophies); print(io, "): ")
    show(io, m::MIME"text/plain", p.deck)
end