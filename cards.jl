const cards = [
    Card("Newcomer",        1, city,         S, ),
    Card("Talent",          2, city,         S, ),
    Card("Dog",             3, city,         S, ),
    Card("Champion",        4, city,         S, ),
     
    Card("Reporter",        2, city,         A, ), #Effect(onplay, :putundertop),
    Card("Talent",          2, city,         A, ),
    Card("Mascot",          2, city,         B, Effect(ongoing, :unique)),
    Card("Dog",             3, city,         B, ),
    Card("Fan-bus",         6, city,         C, Effect(onplay, :gainfans, strength = 2)), # three of fewer trophies
    Card("Champion",        4, city,         C, ),
     
    Card("Jester",          1, castle,       A, Effect(ongoing, :atleast, Selector(power = 1), strength = 3)),
    Card("Stable Boy",      2, castle,       A, Effect(ongoing, :foreach, Selector(power = 3))),
    Card("Hermit",          2, castle,       A, Effect(ongoing, :nocards, Selector(set = city), strength = 2)),
    Card("Pig",             3, castle,       A, ),
    Card("Blacksmith",      3, castle,       B, Effect(frombench, Selector(set = city))),
    Card("Knight",          3, castle,       B, Effect(ongoing, whenattacking = true, strength = 3)),
    Card("Sorcerer",        4, castle,       B, Effect(onplay, :removebench, Selector(maxpower = 3))),
    Card("Horse",           5, castle,       B, ),
    Card("Bard",            4, castle,       C, Effect(frombench, Selector(), whenattacking = true)),
    Card("Prince",          5, castle,       C, Effect(onflagloss, :removebench, Selector(name = "Prince"))),
    Card("Dragon",          7, castle,       C, ),
   
    Card("Make-up Artist",  1, filmstudio,   A, Effect(frombench, Selector(power = 1), whenattacking = true, strength = 2)),
    Card("Movie Star",      2, filmstudio,   A, Effect(onplay, :benchondeck, Selector(name = "Newcomer"), strength = 2)),
    Card("Gangster",        2, filmstudio,   A, Effect(ongoing, :constant, whenattacking = true, strength = 2)),
    Card("Cat",             3, filmstudio,   A, ),
    Card("Cowboy",          3, filmstudio,   B, Effect(onplay, :decktobench, requireflag = true, foropponent = true)),
    Card("Director",        4, filmstudio,   B, Effect(frombench, Selector(set = filmstudio), whenattacking = true, strength = 2)),
    Card("Comic Character", 4, filmstudio,   B, Effect(onflagloss, :comic, strength = 2)),
    Card("Lion",            5, filmstudio,   B, ),
    Card("Heroine",         5, filmstudio,   C, Effect(onplay, :gainfans, requireflag = true, strength = 3)), #fans
    Card("T-Rex",           7, filmstudio,   C, ),
    Card("Villain",        10, filmstudio,   C, Effect(onplay, :putondeck, Selector(tier = A))),
  
    Card("Clown",           1, funfair,      A, Effect(onplay, :gainfans, requireflag = true, strength = 2)), #fans
    Card("Juggler",         2, funfair,      A, Effect(onplay, :sorttop, strength = 3)),
    Card("Vendor",          2, funfair,      A, Effect(frombench, Selector(set = funfair))),
    Card("Pony",            3, funfair,      A, ),
    Card("Mime",            1, funfair,      B, Effect(ongoing, :empty)),
    Card("Pyrotechnician",  4, funfair,      B, ),
    Card("Clairvoyant",     4, funfair,      B, Effect(onflagloss, :search)),
    Card("Rubber Duck",     5, funfair,      B, ),
    Card("Illusionist",     5, funfair,      C, Effect(ongoing, :empty, requireflag = true)),
    Card("Bumper Car",      6, funfair,      C, Effect(onplay, :sorttop, strength = 3)),
    Card("Teddy Bear",      7, funfair,      C, ),

    Card("Butler",          1, hauntedhouse, A, Effect(onplay, :removebench, strength = 2)),
    Card("Skeleton",        2, hauntedhouse, A, Effect(ongoing, :constant, requireflag = true)),
    Card("Spider",          3, hauntedhouse, A, ),
    Card("Ghost",           1, hauntedhouse, B, Effect(onplay, :removetop, foropponent = true)),
    Card("Teenager",        2, hauntedhouse, B, Effect(ongoing, :foreach, Selector(set = hauntedhouse))),
    Card("Necromancer",     3, hauntedhouse, B, Effect(onplay, :benchondeck, Selector(power = 2))),
    Card("Bat",             5, hauntedhouse, B, ),
    Card("Vampire",         4, hauntedhouse, C, Effect(onplay, :benchondeck, Selector(tier = B))),
    Card("Vacuum Cleaner",  5, hauntedhouse, C, Effect(onplay, :removebench, Selector(), strength = 2)),
    Card("Werewolf",        7, hauntedhouse, C, ),

    Card("Rescue Pod",      1, outerspace,   A, Effect(onflagloss, :removebench, Selector(name = "Rescue Pod"))), # B on exhaust
    Card("Shapeshifter",    2, outerspace,   A, ), # on pick remove card to gain extra card
    Card("A.I.",            2, outerspace,   A, Effect(frombench, Selector(power = 2))),
    Card("Cow",             3, outerspace,   A, ),
    Card("Band",            3, outerspace,   B, Effect(frombench, Selector(set = outerspace))),
    Card("Ufo",             3, outerspace,   B, Effect(onplay, :putunderdeck, Selector(tier = A), strength = 2)),
    Card("Clones",          4, outerspace,   B, ), # on pick gain 1 fan
    Card("Alien",           5, outerspace,   B, ),
    Card("Hologram",        4, outerspace,   C, Effect(onplay, :putondeck, Selector(tier = B), foropponent = true)),
    Card("Sci-fi Geek",     6, outerspace,   C, ), # on pick remove two outerspace card to gain 1 card
    Card("Slime",           7, outerspace,   C, ),

    Card("Merman",          1, shipwreck,    A, Effect(ongoing, :atleast, Selector(set = shipwreck), strength = 3)),
    Card("Treasure",        2, shipwreck,    A, Effect(ongoing, requireflag = true, strength = 2)),
    Card("Sailor",          2, shipwreck,    A, ), #Effect(onplay, :searchunder),
    Card("Parrot",          3, shipwreck,    A, ),
    Card("Cook",            2, shipwreck,    B, Effect(frombench, requireflag = true)),
    Card("Lifeguard",       4, shipwreck,    B, Effect(ongoing, :deck, strength = 2)),
    Card("Navigator",       4, shipwreck,    B, ), #Effect(flagloss, :putundertop),
    Card("Shark",           5, shipwreck,    B, ),
    Card("Siren",           6, shipwreck,    C, Effect(onplay, :removebenchopponent, foropponent = true)),
    Card("Kraken",          7, shipwreck,    C, ),
    Card("Submarine",       9, shipwreck,    C, Effect(onplay, :removebottom)),
]

const Acards = filter(c -> c.tier == A, cards)
const Bcards = filter(c -> c.tier == B, cards)
const Ccards = filter(c -> c.tier == C, cards)
const Scards = filter(c -> c.tier == S, cards);

struct CardDict
    d::Dict{String, Card}
end
Base.getproperty(C::CardDict, sym::Symbol) = getfield(C, :d)[string(sym)]
const Cards = CardDict(Dict(filter(c -> 'a' <= c <= 'z', lowercase(c.name)) => c for c in cards))

function multiplicity(card)
    if card.tier == S
        if card.name == "Newcomer"
            3
        else
            1
        end
    else
        if card.name in ["Pig", "Horse", "Talent", "Dog", "Cat", "Lion", "Pony", "Rubber Duck", 
                        "Spider", "Bat", "Cow", "Alien", "Parrot", "Shark"]
            3
        elseif card.name in ["Dragon", "Champion", "T-Rex", "Teddy Bear", "Werewolf", "Slime", "Kraken"]
            2
        elseif card.name == "Skeleton"
            8
        else
            4
        end
    end
end

function makepile(cards)
    pile = Card[]
    for card in cards
        for i in 1:multiplicity(card)
            push!(pile, card)
        end
    end
    pile
end