@enum Set city castle filmstudio funfair hauntedhouse shipwreck outerspace noset
@enum Tier S A B C notier
@enum Trigger frombench ongoing onplay onflagloss notrigger

function setcolor(s::Set)
    Dict(castle => "#3d87bf", city => "#7ec4da", filmstudio => "#53921a", funfair => "#f9b322", hauntedhouse => "#f1822d", outerspace => "#d9080a", shipwreck => "#8b318b", noset => "#ffffff")[s]
end

struct Selector
    name::Union{Nothing, String}
    minpower::Int
    maxpower::Int
    set::Union{Nothing, Set}
    tier::Union{Nothing, Tier}
    invert::Bool
end

function Selector(; name = nothing, power = nothing, set = nothing, tier = nothing, invert = false, minpower = -1, maxpower = 1000)
    if !isnothing(power)
        minpower = power
        maxpower = power
    end
    Selector(name, minpower, maxpower, set, tier, invert)
end

Base.broadcastable(s::Selector) = Ref(s)

struct Effect
    trigger::Trigger
    keyword::Symbol
    selector::Selector
    strength::Int
    whenattacking::Bool
    foropponent::Bool
    requireflag::Bool
end

function Effect(trigger::Trigger = notrigger, keyword = :none, selector = Selector(); strength = 1, 
                whenattacking = false, foropponent = false, requireflag = false)
    Effect(trigger, keyword, selector, strength, whenattacking, foropponent, requireflag)
end

function Effect(trigger::Trigger, selector::Selector; kwargs...)
    Effect(trigger, :none, selector; kwargs...)
end

mutable struct Card
    const name::String
    const power::Int
    const set::Set
    const tier::Tier
    const effect::Effect
    
    function Card(name = "", power = 1, set = noset, tier = notier, effect = Effect())
        new(name, power, set, tier, effect)
    end
end

basepower(c::Card) = c.power
power(c::Card) = c.power
name(c::Card) = c.name
tier(c::Card) = c.tier
set(c::Card) = c.set
setcolor(c::Card) = setcolor(c.set)

Base.broadcastable(c::Card) = Ref(c)

function matches(s::Selector, c::Card)
    !isnothing(s.name) && s.name != c.name && return s.invert
    s.minpower > c.power && return s.invert
    s.maxpower < c.power && return s.invert
    !isnothing(s.set) && s.set != c.set && return s.invert
    !isnothing(s.tier) && s.tier != c.tier && return s.invert
    return !s.invert
end

includet("cards.jl")


function Base.string(c::Card)
    "$(c.name) $(c.power)"
end

function Base.show(io::IO, c::Card)
    print(io, "Card(")
    show(io, c.name); print(io, ", ")
    show(io, c.power); print(io, ", ")
    show(io, c.set); print(io, ", ")
    show(io, c.tier)
    c.effect.trigger != notrigger && print(io, ", Effect($(c.effect.trigger), ...)")
    print(io, ")")
end

mutable struct State
    toplay::Bool
    const deck::Tuple{Vector{Card}, Vector{Card}}
    const bench::Tuple{Vector{Card}, Vector{Card}}
    const field::Tuple{Vector{Card}, Vector{Card}}
    const nbench::MVector{2, Int}
    const comic::MVector{2, Int}
end

function State()
    State(Card[], Card[])
end

function State(deck1, deck2; copydecks = true, shuffle = false)
    copydecks && (deck1 = copy(deck1); deck2 = copy(deck2))
    shuffle && (shuffle!(deck1); shuffle!(deck2))
    State(false, (deck1, deck2), (Card[], Card[]), (Card[], Card[]), [0,0], [0,0])
end

Base.broadcastable(s::State) = Ref(s)
Base.copy(state::State) = State(state.toplay, copy.(state.deck), copy.(state.bench), copy.(state.field), copy(state.nbench))

function Base.empty!(state::State)
    empty!(state.bench[1]); empty!(state.bench[2])
    empty!(state.field[1]); empty!(state.field[2])
    empty!(state.deck[1]); empty!(state.deck[2])
    state.nbench .= 0
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

function addbench!(state::State, player, card::Card)
    if all(card.name != b.name for b in state.bench[player])
        state.nbench[player] += 1
    end
    push!(state.bench[player], card)
end

function removebench!(state::State, player, index)
    card = popat!(state.bench[player], index)
    if all(card.name != b.name for b in state.bench[player])
        state.nbench[player] -= 1
    end
    card
end

function power(card::Card, state::State, player, hasflag = false)
    power = card.power

    for c in state.bench[player]
        if c.effect.trigger == frombench
            if (!c.effect.requireflag || hasflag) && (!c.effect.whenattacking || player == state.toplay + 1)
                if matches(c.effect.selector, card)
                    power += c.effect.strength
                end
            end
        end
    end

    if card.effect.trigger == ongoing
        if (!card.effect.whenattacking || player == state.toplay + 1) && (!card.effect.requireflag || hasflag)
            if card.effect.keyword == :atleast
                if any(matches(card.effect.selector, c) for c in state.bench[player])
                    power += card.effect.strength
                end
            elseif card.effect.keyword == :nocards
                if !any(matches(card.effect.selector, c) for c in state.bench[player])
                    power += card.effect.strength
                end
            elseif card.effect.keyword == :deck
                if length(state.deck[player]) <= 1
                    power += card.effect.strength
                end
            elseif card.effect.keyword == :foreach
                power += card.effect.strength * sum((matches(card.effect.selector, c) for c in state.bench[player]), init = 0)
            elseif card.effect.keyword == :unique
                power += card.effect.strength * length(unique(set, state.bench[player]))
            elseif card.effect.keyword == :empty
                power += card.effect.strength * (6 - state.nbench[player])
            elseif card.effect.keyword == :constant
                power += card.effect.strength
            end
        end
    end
    power
end

function execute!(state, keyword, selector, player, strength)
    deck = state.deck[player]
    bench = state.bench[player]
    if keyword == :removebench
        for _ in 1:strength
            i = findfirst(c -> matches(selector, c), bench)
            !isnothing(i) && removebench!(state, player, i)
        end
    elseif keyword == :benchondeck
        for _ in 1:strength
            i = findfirst(c -> matches(selector, c), bench)
            !isnothing(i) && push!(deck, removebench!(state, player, i))
        end
    elseif keyword == :benchunderdeck
        for _ in 1:strength
            i = findfirst(c -> matches(selector, c), bench)
            !isnothing(i) && pushfirst!(deck, removebench!(state, player, i))
        end
    elseif keyword == :removetop
        for _ in 1:strength
            !isempty(deck) && pop!(deck)
        end
    elseif keyword == :removebottom
        for _ in 1:strength
            !isempty(deck) && popfirst!(deck)
        end
    elseif keyword == :decktobench
        for _ in 1:strength
            !isempty(deck) && addbench!(state, player, popfirst!(deck))
        end
    elseif keyword == :putondeck
        cards = if !isnothing(selector.tier)
            Dict(A => Acards, B => Bcards, C => Ccards)[selector.tier]
        else
            filter(c -> matches(selector, c), cards)
        end
        for _ in 1:strength
            push!(deck, rand(cards))
        end
    elseif keyword == :putunderdeck
        cards = if !isnothing(selector.tier)
            Dict(A => Acards, B => Bcards, C => Ccards)[selector.tier]
        else
            filter(c -> matches(selector, c), cards)
        end
        for _ in 1:strength
            pushfirst!(deck, rand(cards))
        end
    elseif keyword == :removebenchopponent
        for _ in 1:strength
            i = findfirst(c -> c.effect == frombench, bench)
            !isnothing(i) && removebench!(state, player, i)
        end
    elseif keyword == :comic
        state.comic[player] = strength
    elseif keyword == :sorttop
        n = min(length(deck), strength)
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
        # sort!((@view deck[end-n+1:end]), by = c -> (c.onplay.keyword != :nothing) * 1 - c.power, rev = false)
        # sort!((@view deck[end-n+1:end]), by = c -> power(c, state, player) >= tobeat, rev = false)
    elseif keyword == :search
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
            if deck[i].effect.trigger != notrigger
            # if deck[i].frombench.strength != 0
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

function onplay!(card::Card, state::State, player, hasflag = false)
    if card.effect.trigger == onplay && card.effect.requireflag == hasflag
        if card.effect.foropponent
            player = ifelse(player == 1, 2, 1)
        end
        execute!(state, card.effect.keyword, card.effect.selector, player, card.effect.strength)
    end
end

function onflagloss!(card::Card, state::State, player)
    if card.effect.trigger == onflagloss
        if card.effect.foropponent
            player = ifelse(player == 1, 2, 1)
        end
        execute!(state, card.effect.keyword, card.effect.selector, player, card.effect.strength)
    end
end

function simulate!(state::State; output = false)
    (; deck, bench, field, nbench) = state

    for i in 1:1000
        a = state.toplay + 1; d = !state.toplay + 1

        if isempty(deck[a])
            output && println("Player $a empty deck")
            return d
        end
        card = pop!(deck[a])
        push!(field[a], card)
        onplay!(card, state, a, false)

        attackpower = sum(c -> power(c, state, a), field[a], init = 0) + state.comic[a]
        defensepower = (isempty(field[d]) ? 0 : power(field[d][end], state, d, true))

        if attackpower >= defensepower
            onplay!(card, state, a, true)
            for c in field[d]
                addbench!(state, d, c)
            end
            empty!(field[d])
            !isempty(bench[d]) && onflagloss!(bench[d][end], state, d)

            state.comic[a] = 0
            state.toplay = !state.toplay
        end
        if nbench[d] > 6
            output && println("Player $d bench full")    
            return a
        end
    
        output && (show(state); println())
    end
    0
end

simulate(state::State; kwargs...) = simulate!(copy(state); kwargs...)

function winrate(state::State; kwargs...)
    winrate(k -> state; kwargs...)
end

function winrate(f::Function; randomplayer = true, nsamples = 1000, shuffledecks = true, showprogress = false, state = State())
    prog = Progress(nsamples, enabled = showprogress)
    sum(1:nsamples) do k
        reset!(state, f(k))
        shuffledecks && shuffle!(state.deck[1])
        shuffledecks && shuffle!(state.deck[2])
        randomplayer && (state.toplay = rand(Bool))
        w = simulate!(state)
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