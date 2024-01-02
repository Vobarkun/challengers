mutable struct Deck
    nunique::Int
    cards::Vector{Card}
    values::Vector{Int}
    fixed::Vector{Bool}
end

Deck(cards) = Deck(length(unique(cards)), cards, [power(c) * sum(isequal(c.name) ∘ name, cards) for c in cards], fill(false, length(cards)))
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
    deck.values[inds] .= card.power * length(inds) + 100any(deck.fixed[inds])

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
end

function optimize!(deck::Deck; nsamples = 10)
    state = State()
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
    for _ in 1:imax-1
        popfirst!(deck)
    end
    strength
end

# function slotcost(card)
#     if card.effect.keyword == :removebench
#         -card.effect.strength
#     elseif
#         card.effect.keyword == :putondeck
#     end
# end

# function optimize!(deck::Deck; nsamples = 0)
#     # sort!(deck.cards, by = c -> power(c) * sum(isequal(c), deck.cards))
#     # powers = [power(c) * sum(isequal(c), deck.cards) for c in deck.cards]
#     # deck.cards .= deck.cards[sortperm(powers)]
#     while deck.nunique > 6
#         popfirst!(deck)
#     end
#     deck
# end


