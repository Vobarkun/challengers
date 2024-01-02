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
    const id::Int
    const effect::Effect
    
    function Card(name = "", power = 1, set = noset, tier = notier, id = nothing, effect = Effect())
        new(name, power, set, tier, isnothing(id) ? reinterpret(Int, hash(name)) : id, effect)
    end
end

basepower(c::Card) = c.power
power(c::Card) = c.power
name(c::Card) = c.name
tier(c::Card) = c.tier
set(c::Card) = c.set
id(c::Card) = c.id
setcolor(c::Card) = setcolor(c.set)

Base.broadcastable(c::Card) = Ref(c)

function Base.:(==)(c1::Card, c2::Card)
    c1.name == c2.name && c1.power == c2.power && c1.set == c2.set && c1.tier == c2.tier && c1.effect == c2.effect
end

function Base.hash(c::Card, h::UInt)
    h = hash(c.name, h)
    h = hash(c.power, h)
    h = hash(c.set, h)
    h = hash(c.tier, h)
    h = hash(c.effect, h)
end

function matches(s::Selector, c::Card)
    !isnothing(s.name) && s.name != c.name && return s.invert
    s.minpower > c.power && return s.invert
    s.maxpower < c.power && return s.invert
    !isnothing(s.set) && s.set != c.set && return s.invert
    !isnothing(s.tier) && s.tier != c.tier && return s.invert
    return !s.invert
end

function Base.string(c::Card)
    s = "Card(\"$(c.name)\", $(c.power), c.set, c.tier"
    if c.effect.trigger != notrigger
        s *= ", Effect($(c.effect.trigger), ...)"
    end
    s *= ")"
    s
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
