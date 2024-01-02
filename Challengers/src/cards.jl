const cards = [
    Card("Newcomer",        1, city,         S,  0, ),
    Card("Talent",          2, city,         S,  1, ),
    Card("Dog",             3, city,         S,  2, ),
    Card("Champion",        4, city,         S,  3, ),
    Card("Reporter",        2, city,         A,  4, ), #Effect(onplay, :putundertop),
    Card("Talent",          2, city,         A,  1, ),
    Card("Mascot",          2, city,         B,  6, Effect(ongoing, :unique)),
    Card("Dog",             3, city,         B,  2, ),
    Card("Fan-bus",         6, city,         C,  8, Effect(onplay, :gainfans, strength = 2)), # three of fewer trophies
    Card("Champion",        4, city,         C,  3, ),
    
    Card("Jester",          1, castle,       A, 10,  Effect(ongoing, :atleast, Selector(power = 1), strength = 3)),
    Card("Stable Boy",      2, castle,       A, 11, Effect(ongoing, :foreach, Selector(power = 3))),
    Card("Hermit",          2, castle,       A, 12, Effect(ongoing, :nocards, Selector(set = city), strength = 2)),
    Card("Pig",             3, castle,       A, 13, ),
    Card("Blacksmith",      3, castle,       B, 14, Effect(frombench, Selector(set = city))),
    Card("Knight",          3, castle,       B, 15, Effect(ongoing, whenattacking = true, strength = 3)),
    Card("Sorcerer",        4, castle,       B, 16, Effect(onplay, :removebench, Selector(maxpower = 3))),
    Card("Horse",           5, castle,       B, 17, ),
    Card("Bard",            4, castle,       C, 18, Effect(frombench, Selector(), whenattacking = true)),
    Card("Prince",          5, castle,       C, 19, Effect(onflagloss, :removebench, Selector(name = "Prince"))),
    Card("Dragon",          7, castle,       C, 20, ),

    Card("Make-up Artist",  1, filmstudio,   A, 21, Effect(frombench, Selector(power = 1), whenattacking = true, strength = 2)),
    Card("Movie Star",      2, filmstudio,   A, 22, Effect(onplay, :benchondeck, Selector(name = "Newcomer"), strength = 2)),
    Card("Gangster",        2, filmstudio,   A, 23, Effect(ongoing, :constant, whenattacking = true, strength = 2)),
    Card("Cat",             3, filmstudio,   A, 24, ),
    Card("Cowboy",          3, filmstudio,   B, 25, Effect(onplay, :decktobench, requireflag = true, foropponent = true)),
    Card("Director",        4, filmstudio,   B, 26, Effect(frombench, Selector(set = filmstudio), whenattacking = true, strength = 2)),
    Card("Comic Character", 4, filmstudio,   B, 27, Effect(onflagloss, :comic, strength = 2)),
    Card("Lion",            5, filmstudio,   B, 28, ),
    Card("Heroine",         5, filmstudio,   C, 29, Effect(onplay, :gainfans, requireflag = true, strength = 3)), #fans
    Card("T-Rex",           7, filmstudio,   C, 30, ),
    Card("Villain",        10, filmstudio,   C, 31, Effect(onplay, :putondeck, Selector(tier = A))),

    Card("Clown",           1, funfair,      A, 32, Effect(onplay, :gainfans, requireflag = true, strength = 2)), #fans
    Card("Juggler",         2, funfair,      A, 33, Effect(onplay, :sorttop, strength = 3)),
    Card("Vendor",          2, funfair,      A, 34, Effect(frombench, Selector(set = funfair))),
    Card("Pony",            3, funfair,      A, 35, ),
    Card("Mime",            1, funfair,      B, 36, Effect(ongoing, :empty)),
    Card("Pyrotechnician",  4, funfair,      B, 37, ),
    Card("Clairvoyant",     4, funfair,      B, 38, Effect(onflagloss, :search)),
    Card("Rubber Duck",     5, funfair,      B, 39, ),
    Card("Illusionist",     5, funfair,      C, 40, Effect(ongoing, :empty, requireflag = true)),
    Card("Bumper Car",      6, funfair,      C, 41, Effect(onplay, :sorttop, strength = 3)),
    Card("Teddy Bear",      7, funfair,      C, 42, ),

    Card("Butler",          1, hauntedhouse, A, 43, Effect(onplay, :removebench, strength = 2)),
    Card("Skeleton",        2, hauntedhouse, A, 44, Effect(ongoing, :constant, requireflag = true)),
    Card("Spider",          3, hauntedhouse, A, 45, ),
    Card("Ghost",           1, hauntedhouse, B, 46, Effect(onplay, :removetop, foropponent = true)),
    Card("Teenager",        2, hauntedhouse, B, 47, Effect(ongoing, :foreach, Selector(set = hauntedhouse))),
    Card("Necromancer",     3, hauntedhouse, B, 48, Effect(onplay, :benchondeck, Selector(power = 2))),
    Card("Bat",             5, hauntedhouse, B, 49, ),
    Card("Vampire",         4, hauntedhouse, C, 50, Effect(onplay, :benchondeck, Selector(tier = B))),
    Card("Vacuum Cleaner",  5, hauntedhouse, C, 51, Effect(onplay, :removebench, Selector(), strength = 2)),
    Card("Werewolf",        7, hauntedhouse, C, 52, ),

    Card("Rescue Pod",      1, outerspace,   A, 53, Effect(onflagloss, :removebench, Selector(name = "Rescue Pod"))), # B on exhaust
    Card("Shapeshifter",    2, outerspace,   A, 54, ), # on pick remove card to gain extra card
    Card("A.I.",            2, outerspace,   A, 55, Effect(frombench, Selector(power = 2))),
    Card("Cow",             3, outerspace,   A, 56, ),
    Card("Band",            3, outerspace,   B, 57, Effect(frombench, Selector(set = outerspace))),
    Card("Ufo",             3, outerspace,   B, 58, Effect(onplay, :putunderdeck, Selector(tier = A), strength = 2)),
    Card("Clones",          4, outerspace,   B, 59, ), # on pick gain 1 fan
    Card("Alien",           5, outerspace,   B, 60, ),
    Card("Hologram",        4, outerspace,   C, 61, Effect(onplay, :putondeck, Selector(tier = B), foropponent = true)),
    Card("Sci-fi Geek",     6, outerspace,   C, 62, ), # on pick remove two outerspace card to gain 1 card
    Card("Slime",           7, outerspace,   C, 63, ),

    Card("Merman",          1, shipwreck,    A, 64, Effect(ongoing, :atleast, Selector(set = shipwreck), strength = 3)),
    Card("Treasure",        2, shipwreck,    A, 65, Effect(ongoing, requireflag = true, strength = 2)),
    Card("Sailor",          2, shipwreck,    A, 66, ), #Effect(onplay, :searchunder),
    Card("Parrot",          3, shipwreck,    A, 67, ),
    Card("Cook",            2, shipwreck,    B, 68, Effect(frombench, requireflag = true)),
    Card("Lifeguard",       4, shipwreck,    B, 69, Effect(ongoing, :deck, strength = 2)),
    Card("Navigator",       4, shipwreck,    B, 70, ), #Effect(flagloss, :putundertop),
    Card("Shark",           5, shipwreck,    B, 71, ),
    Card("Siren",           6, shipwreck,    C, 72, Effect(onplay, :removebenchopponent, foropponent = true)),
    Card("Kraken",          7, shipwreck,    C, 73, ),
    Card("Submarine",       9, shipwreck,    C, 74, Effect(onplay, :removebottom)),
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