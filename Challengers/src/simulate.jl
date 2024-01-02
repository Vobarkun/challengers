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

function calculateStrength!(state, a = 1)
    (; deck, bench, field, nbench) = state

    s = 0
    for i in 1:1000
        if isempty(deck[a]) || nbench[a] > 6
            return s
        end
        card = pop!(deck[a])
        onplay!(card, state, a, false)
        onplay!(card, state, a, true)
        s += power(card, state, a) + state.comic[a]
        state.comic[a] = 0
        addbench!(state, a, card)
        onflagloss!(card, state, a)
    end
    0
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

winrate(state::State; kwargs...) = winrate(k -> state; kwargs...)
winrate(deck::Vector{Card}, opponents; kwargs...) = winrate(k -> (deck = (deck, opponents[mod1(k, length(opponents))]),); kwargs...)
winrate(deck::Vector{Card}, opponent::Vector{Card}; kwargs...) = winrate(deck, (opponent, ); kwargs...)