module Challengers

using StaticArrays, StatsBase, Random, ProgressMeter

@enum Set city castle filmstudio funfair hauntedhouse shipwreck outerspace noset
@enum Tier S A B C notier
@enum Trigger frombench ongoing onplay onflagloss notrigger

function setcolor(s::Set)
    Dict(castle => "#3d87bf", city => "#7ec4da", filmstudio => "#53921a", funfair => "#f9b322", hauntedhouse => "#f1822d", outerspace => "#d9080a", shipwreck => "#8b318b", noset => "#ffffff")[s]
end

include("Card.jl")
include("cards.jl")
include("CardPile.jl")
include("Deck.jl")
include("State.jl")
include("simulate.jl")


export Selector, Effect, Card, basepower, power, name, tier, set, id, setcolor, Set, Tier, Trigger, matches
export CardPile, draw!, draw, ret!
export Deck, optimize!
export State, reset!, addbench!, removebench!
export simulate!, simulate, winrate
export makepile, Acards, Bcards, Ccards, Scards, Cards

end # module Challengers
