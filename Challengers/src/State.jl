mutable struct State
    toplay::Bool
    const deck::Tuple{Vector{Card}, Vector{Card}}
    const bench::Tuple{Vector{Card}, Vector{Card}}
    const field::Tuple{Vector{Card}, Vector{Card}}
    const gained::Tuple{Vector{Card}, Vector{Card}}
    const lost::Tuple{Vector{Card}, Vector{Card}}
    const nbench::MVector{2, Int}
    const comic::MVector{2, Int}
    const fans::MVector{2, Int}
    const ntrophies::MVector{2, Int}
end

function State()
    State(Card[], Card[])
end

function State(deck1, deck2; copydecks = true, shuffle = false)
    copydecks && (deck1 = copy(deck1); deck2 = copy(deck2))
    shuffle && (shuffle!(deck1); shuffle!(deck2))
    State(false, (deck1, deck2), (Card[], Card[]), (Card[], Card[]), (Card[], Card[]), (Card[], Card[]), MVector(0,0), MVector(0,0), MVector(0,0),  MVector(0,0))
end

Base.broadcastable(s::State) = Ref(s)
Base.copy(state::State) = State(state.toplay, copy.(state.deck), copy.(state.bench), copy.(state.field), copy.(state.gained), copy.(state.lost), 
                                copy(state.nbench), copy(state.comic), copy(state.fans), copy(state.ntrophies))

function Base.empty!(state::State)
    empty!(state.bench[1]); empty!(state.bench[2])
    empty!(state.field[1]); empty!(state.field[2])
    empty!(state.gained[1]); empty!(state.gained[2])
    empty!(state.lost[1]); empty!(state.lost[2])
    empty!(state.deck[1]); empty!(state.deck[2])
    state.nbench .= 0
    state.comic .= 0
    state.fans .= 0
    state.ntrophies .= 0
    state
end

function reset!(state1, state2)
    empty!(state1)
    resize!(state1.deck[1], length(state2.deck[1]))
    state1.deck[1] .= state2.deck[1]
    resize!(state1.deck[2], length(state2.deck[2]))
    state1.deck[2] .= state2.deck[2]
    state1
end

reset!(state1, deck1, deck2) = reset!(state1, (deck = (deck1, deck2),))

function addbench!(state::State, player, card::Card)
    if all(card.id != b.id for b in state.bench[player])
        state.nbench[player] += 1
    end
    push!(state.bench[player], card)
end

function removebench!(state::State, player, index)
    card = popat!(state.bench[player], index)
    if all(card.id != b.id for b in state.bench[player])
        state.nbench[player] -= 1
    end
    card
end

function Base.show(io::IO, state::State)
    print(io, "Deck 1: "); print(io, length(state.deck[1])); print(io, " cards")
    println(io)
    print(io, "Bench 1: ")
    for c in state.bench[1]
        print(io, name(c)); print(io, " ")
    end
    println(io)
    print(io, "Field 1: ")
    for c in state.field[1]
        print(io, string(c))
        if c.effect.trigger == ongoing
            print(io, "+"); print(io, power(c, state, 1) - c.power);
        end
        print(io, " ")
    end
    println(io)
        
    print(io, "Field 2: ")
    for c in state.field[2]
        print(io, string(c))
        if c.effect.trigger == ongoing
            print(io, "+"); print(io, power(c, state, 2) - c.power);
        end
        print(io, " ")
    end
    println(io)
    print(io, "Bench 2: ")
    for c in state.bench[2]
        print(io, name(c)); print(io, " ")
    end
    println(io)
    print(io, "Deck 2: "); print(io, length(state.deck[2])); print(io, " cards")
    println(io)
end