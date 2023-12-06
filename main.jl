struct Selector
    name::Union{Nothing, String}
    power::Union{Nothing, Int}
    set::Union{Nothing, String}
    origin::Union{Nothing, String}
    maxpower::Union{Nothing, Int}
    invert::Bool
end

function Selector(; name = nothing, power = nothing, set = nothing, origin = nothing, invert = false, maxpower = nothing)
    Selector(name, power, set, origin, maxpower, invert)
end

struct Card
    name::String
    power::Int
    set::String
    origin::String

    frombench::NamedTuple{(:selector, :attacking, :value), Tuple{Selector, Bool, Int64}}
    ongoing::NamedTuple{(:selector, :mode, :attacking, :flag, :value), Tuple{Selector, Symbol, Bool, Bool, Int64}}
    onplay::NamedTuple{(:selector, :effect, :opponent, :flag, :value), Tuple{Selector, Symbol, Bool, Bool, Int64}}
    onflagloss::NamedTuple{(:selector, :effect, :opponent, :attacking, :value), Tuple{Selector, Symbol, Bool, Bool, Int64}}
end

function Card(name, power, set, origin; 
    frombench = (Selector(), false, 0), 
    ongoing = (Selector(), :nothing, false, false, 0), 
    onplay = (Selector(), :nothing, false, false, 0),
    onflagloss = (Selector(), :nothing, false, false, 0)
)
    frombench = NamedTuple{(:selector, :attacking, :value), Tuple{Selector, Bool, Int64}}(frombench)
    ongoing = NamedTuple{(:selector, :mode, :attacking, :flag, :value), Tuple{Selector, Symbol, Bool, Bool, Int64}}(ongoing)
    onplay = NamedTuple{(:selector, :effect, :opponent, :flag, :value), Tuple{Selector, Symbol, Bool, Bool, Int64}}(onplay)
    onflagloss = NamedTuple{(:selector, :effect, :opponent, :attacking, :value), Tuple{Selector, Symbol, Bool, Bool, Int64}}(onflagloss)
    Card(name, power, set, origin, frombench, ongoing, onplay, onflagloss)
end

function Card(; name = "none", power = 1, set = "none", origin = "N", kwargs...)
    Card(name, power, set, origin; kwargs...)
end

basepower(c::Card) = c.power
name(c::Card) = c.name
origin(c::Card) = c.origin
set(c::Card) = c.set



includet("cards.jl")

struct CardDict
    d::Dict{String, Card}
end
Base.getproperty(C::CardDict, sym::Symbol) = getfield(C, :d)[string(sym)]
const C = CardDict(merge(starter, city, castle, filmstudio, funfair, hauntedhouse, outerspace, shipwreck))


function match(s::Selector, c::Card)
    !isnothing(s.name) && s.name != c.name && return s.invert
    !isnothing(s.power) && s.power != c.power && return s.invert
    !isnothing(s.maxpower) && s.maxpower < c.power && return s.invert
    !isnothing(s.set) && s.set != c.set && return s.invert
    !isnothing(s.origin) && s.origin != c.origin && return s.invert
    return !s.invert
end

function Base.string(c::Card)
    "$(c.name): $(c.power)"
end

mutable struct State
    toplay::Bool
    deck::Tuple{Vector{Card}, Vector{Card}}
    bench::Tuple{Vector{Card}, Vector{Card}}
    field::Tuple{Vector{Card}, Vector{Card}}
end

function State(deck1, deck2; copydecks = true, shuffle = false)
    copydecks && (deck1 = copy(deck1); deck2 = copy(deck2))
    shuffle && (shuffle!(deck1); shuffle!(deck2))
    State(false, (deck1, deck2), (Card[], Card[]), (Card[], Card[]))
end

function power(card::Card, state::State, player, flag = false)
    power = card.power

    for c in state.bench[player]
        if match(c.frombench.selector, card)
            if !c.frombench.attacking || player == state.toplay + 1
                power += c.frombench.value
            end
        end
    end
    if (!card.ongoing.attacking || player == state.toplay + 1) && (!card.ongoing.flag || flag)
        if card.ongoing.mode == :atleast
            if any(match(card.ongoing.selector, c) for c in state.bench[player])
                power += card.ongoing.value
            end
        elseif card.ongoing.mode == :nocards
            if !any(match(card.ongoing.selector, c) for c in state.bench[player])
                power += card.ongoing.value
            end
        elseif card.ongoing.mode == :deck
            if length(state.deck[player]) <= 1
                power += card.ongoing.value
            end
        elseif card.ongoing.mode == :foreach
            power += card.ongoing.value * sum((match(card.ongoing.selector, c) for c in state.bench[player]), init = 0)
        elseif card.ongoing.mode == :unique
            power += card.ongoing.value * length(unique(c.set for c in state.bench[player]))
        elseif card.ongoing.mode == :empty
            power += card.ongoing.value * (6 - length(unique(name, state.bench[player])))
        elseif card.ongoing.mode == :none
            power += card.ongoing.value
        end
    end
    
    power
end

function execute!(state, effect, selector, player, value)
    deck = state.deck[player]
    bench = state.bench[player]
    if effect == :removebench
        for _ in 1:value
            i = findfirst(c -> match(selector, c), bench)
            !isnothing(i) && popat!(bench, i)
        end
    elseif effect == :benchondeck
        for _ in 1:value
            i = findfirst(c -> match(selector, c), bench)
            !isnothing(i) && push!(deck, popat!(bench, i))
        end
    elseif effect == :benchunderdeck
        for _ in 1:value
            i = findfirst(c -> match(selector, c), bench)
            !isnothing(i) && pushfirst!(deck, popat!(bench, i))
        end
    elseif effect == :removetop
        for _ in 1:value
            !isempty(deck) && pop!(deck)
        end
    elseif effect == :removebottom
        for _ in 1:value
            !isempty(deck) && popfirst!(deck)
        end
    elseif effect == :decktobench
        for _ in 1:value
            !isempty(deck) && push!(bench, popfirst!(deck))
        end
    elseif effect == :putondeck
        cards = if !isnothing(selector.origin)
            Dict("A" => Acards, "B" => Bcards, "C" => Ccards)[selector.origin]
        else
            filter(c -> match(selector, c), allcards)
        end
        for _ in 1:value
            push!(deck, rand(cards))
        end
    elseif effect == :putunderdeck
        cards = if !isnothing(selector.origin)
            Dict("A" => Acards, "B" => Bcards, "C" => Ccards)[selector.origin]
        else
            filter(c -> match(selector, c), allcards)
        end
        for _ in 1:value
            pushfirst!(deck, rand(cards))
        end
    elseif effect == :sorttop
        n = min(length(deck), value)
        n <= 1 && return
        opponent = ifelse(player == 1, 2, 1)
        tobeat = (isempty(state.field[opponent]) ? 0 : power(state.field[opponent][end], state, opponent, true))
        tobeat = max(0, tobeat - sum(c -> power(c, state, player), state.field[player], init = 0))
        sort!((@view deck[end-n+1:end]), by = basepower, rev = true)
        for i in 0:n-1
            if power(deck[end-i], state, player) >= tobeat
                deck[end], deck[end-i] = deck[end-i], deck[end]
                break
            end
        end
        # sort!((@view deck[end-n+1:end]), by = c -> (c.onplay.effect != :nothing) * 1 - c.power, rev = false)
        # sort!((@view deck[end-n+1:end]), by = c -> power(c, state, player) >= tobeat, rev = false)
    elseif effect == :search
        deck = deck
        length(deck) <= 1 && return
        opponent = ifelse(player == 1, 2, 1)
        tobeat = (isempty(state.field[opponent]) ? 0 : power(state.field[opponent][end], state, opponent, true))
        tobeat = max(0, tobeat - sum(c -> power(c, state, player), state.field[player], init = 0))
        # sort!((@view deck[end-n+1:end]), by = basepower, rev = true)
        # inds = filter(i -> power(deck[i], state, player) >= tobeat, 1:length(deck))
        # isempty(inds) && return
        # i = argmax(i -> power(deck[i], state, player), inds)
        # # i = argmax(power.(deck, Ref(state), player))
        # deck[end], deck[i] = deck[i], deck[end]
        for i in 1:length(deck)
            if deck[i].onplay.effect != :nothing || deck[i].frombench.value != 0 || deck[i].onflagloss.effect != :nothing
            # if deck[i].frombench.value != 0
                deck[end], deck[i] = deck[i], deck[end]
                break
            end
        end
        # for i in 1:length(deck)
        #     if power(deck[i], state, player) >= tobeat
        #         deck[end], deck[i] = deck[i], deck[end]
        #         break
        #     end
        # end
        # sort!((@view deck[end-n+1:end]), by = c -> (c.onplay.effect != :nothing) * 1 - c.power, rev = false)
        # sort!((@view deck[end-n+1:end]), by = c -> power(c, state, player) >= tobeat, rev = false)
    end
end

function onplay(card::Card, state::State, player, flag = false)
    if card.onplay.flag == flag
        if card.onplay.opponent
            player = ifelse(player == 1, 2, 1)
        end
        execute!(state, card.onplay.effect, card.onplay.selector, player, card.onplay.value)
    end
end

function onflagloss(card::Card, state::State, player)
    if card.onflagloss.opponent
        player = ifelse(player == 1, 2, 1)
    end
    execute!(state, card.onflagloss.effect, card.onflagloss.selector, player, card.onflagloss.value)
end

function simulate!(state::State; output = false)
    (; deck, bench, field) = state

    for i in 1:100
        a = state.toplay + 1; d = !state.toplay + 1

        if isempty(deck[a])
            output && println("Player $a empty deck")
            return d
        end
        card = pop!(deck[a])
        push!(field[a], card)
        onplay(card, state, a, false)
        if sum(c -> power(c, state, a), field[a], init = 0) >= (isempty(field[d]) ? 0 : power(field[d][end], state, d, true))
            onplay(card, state, a, true)

            cards = copy(field[d])
            append!(bench[d], field[d]); empty!(field[d])
            for c in cards
                onflagloss(c, state, d)
            end

            state.toplay = !state.toplay
        end
        if length(unique(name, bench[d])) > 6
            output && println("Player $d bench full")    
            return a
        end
    
        output && (show(state); println())
    end
end

simulate(state::State; kwargs...) = simulate!(deepcopy(state); kwargs...)

function winrate(state::State; kwargs...)
    function f()
        s = deepcopy(state)
        shuffle!(s.deck[1])
        shuffle!(s.deck[2])
        s
    end
    winrate(f; kwargs...)
end

function winrate(f::Function; randomplayer = true, nsamples = 1000, showprogress = false)
    prog = Progress(nsamples, enabled = showprogress)
    sum(1:nsamples) do _
        s = f()
        randomplayer && (s.toplay = rand(Bool))
        w = simulate!(s)
        next!(prog)
        w == 1
    end / nsamples
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
        if c.ongoing.mode != :nothing
            print(io, "+"); print(io, power(c, state, 1) - c.power);
        end
        print(io, " ")
    end
    println(io)
        
    print(io, "Field 2: ")
    for c in state.field[2]
        print(io, string(c))
        if c.ongoing.mode != :nothing
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