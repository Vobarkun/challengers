const starter = Dict(
    "newcomer" => Card("Newcomer", 1, "city", "S"),
    "talent"   => Card("Talent", 2, "city", "S"),
    "dog"      => Card("Dog", 3, "city", "S"),
    "champion" => Card("Champion", 4, "city", "S")
)

const city = Dict(
    # "reporter"     => Card("Reporter", 2, "city", "A", onplay = ), # lookat
    "citytalent"   => Card("Talent", 2, "city", "A"),
    "mascot"       => Card("Mascot", 2, "city", "B", ongoing = (Selector(), :unique, false, false, 1)),
    "citydog"      => Card("Dog", 3, "city", "B"),
    "fanbus"       => Card("Fan-bus", 6, "city", "C"), # fans
    "citychampion" => Card("Champion", 4, "city", "C")
)

const castle = Dict(
    "jester"     => Card("Jester", 1, "castle", "A", ongoing = (Selector(power = 1), :atleast, false, false, 3)),
    "stableboy"  => Card("Stable Boy", 2, "castle", "A", ongoing = (Selector(power = 3), :foreach, false, false, 1)),
    "hermit"     => Card("Hermit", 2, "castle", "A", ongoing = (Selector(set = "city"), :nocards, false, false, 2)),
    "pig"        => Card("Pig", 3, "castle", "A"),
    "blacksmith" => Card("Blacksmith", 3, "castle", "B", frombench = (Selector(set = "city"), false, 1)),
    "knight"     => Card("Knight", 3, "castle", "B", ongoing = (Selector(), :none, true, false, 3)),
    "sorcerer"   => Card("Sorcerer", 4, "castle", "B", onplay = (Selector(maxpower = 3), :removebench, false, false, 1)), # or lower
    "horse"      => Card("Horse", 5, "castle", "B"),
    "bard"       => Card("Bard", 4, "castle", "C", frombench = (Selector(), true, 1)),
    "prince"     => Card("Prince", 5, "castle", "C", onflagloss = (Selector(name = "Prince"), :removebench, false, false, 1)),
    "dragon"     => Card("Dragon", 7, "castle", "C")
)

const filmstudio = Dict(
    "makeupartist"   => Card("Make-up Artist", 1, "filmstudio", "A", frombench = (Selector(power = 1), true, 2)),
    "moviestar"      => Card("Movie Star", 2, "filmstudio", "A", onplay = (Selector(name = "Newcomer"), :benchondeck, false, false, 2)),
    "gangster"       => Card("Gangster", 2, "filmstudio", "A", ongoing = (Selector(), :none, true, false, 2)),
    "cat"            => Card("Cat", 3, "filmstudio", "A"),
    "cowboy"         => Card("Cowboy", 3, "filmstudio", "B", onplay = (Selector(), :decktobench, true, true, 1)),
    "director"       => Card("Director", 4, "filmstudio", "B", frombench = (Selector(set = "filmstudio"), true, 2)),
    # "comiccharacter" => Card("Comic Character", 4, "filmstudio", "B", onflagloss = (Selector(), :buffnextcard, false, true, 2)),
    "lion"           => Card("Lion", 5, "filmstudio", "B"),
    "heroine"        => Card("Heroine", 5, "filmstudio", "C"), #fans
    "trex"           => Card("T-Rex", 7, "filmstudio", "C"),
    "villain"        => Card("Villain", 10, "filmstudio", "C", onplay = (Selector(origin = "A"), :putondeck, false, false, 1)),
)

const funfair = Dict(
    "clown"          => Card("Clown", 1, "funfair", "A"), #fans
    "juggler"        => Card("Juggler", 2, "funfair", "A", onplay = (Selector(), :sorttop, false, false, 3)),
    "vendor"         => Card("Vendor", 2, "funfair", "A", frombench = (Selector(set = "funfair"), false, 1)),
    "pony"           => Card("Pony", 3, "funfair", "A"),
    "mime"           => Card("Mime", 1, "funfair", "B", ongoing = (Selector(), :empty, false, false, 1)),
    "pyrotechnician" => Card("Pyrotechnician", 4, "funfair", "B"),
    "clairvoyant"    => Card("Clairvoyant", 4, "funfair", "B", onflagloss = (Selector(), :search, false, false, 1)),
    "rubberduck"     => Card("Rubber Duck", 5, "funfair", "B"),
    "illusionist"    => Card("Illusionist", 6, "funfair", "C", ongoing = (Selector(), :empty, false, true, 1)),
    "bumpercar"      => Card("Bumper Car", 1, "funfair", "C", onplay = (Selector(), :sorttop, false, false, 3)),
    "teddybear"      => Card("Teddy Bear", 7, "funfair", "C"),
)

const hauntedhouse = Dict(
    "butler"        => Card("Butler", 1, "hauntedhouse", "A", onplay = (Selector(), :removebench, false, false, 2)),
    "skeleton"      => Card("Skeleton", 2, "hauntedhouse", "A", ongoing = (Selector(), :none, false, true, 1)),
    "spider"        => Card("Spider", 3, "hauntedhouse", "A"),
    "ghost"         => Card("Ghost", 1, "hauntedhouse", "B", onplay = (Selector(), :removetop, true, false, 1)),
    "teenager"      => Card("Teenager", 2, "hauntedhouse", "B", ongoing = (Selector(set = "hauntedhouse"), :foreach, false, false, 1)),
    "necromancer"   => Card("Necromancer", 3, "hauntedhouse", "B", onplay = (Selector(power = 2), :benchondeck, false, false, 1)),
    "bat"           => Card("Bat", 5, "hauntedhouse", "B"),
    "vampire"       => Card("Vampire", 4, "hauntedhouse", "C", onplay = (Selector(origin = "B"), :benchondeck, false, false, 1)),
    "vacuumcleaner" => Card("Vacuum Cleaner", 5, "hauntedhouse", "C", onplay = (Selector(), :removebench, false, false, 2)),
    "werewolf"      => Card("Werewolf", 7, "hauntedhouse", "C"),
)

const outerspace = Dict(
    "rescuepod"    => Card("Rescue Pod", 1, "outerspace", "A", onflagloss = (Selector(name = "Rescue Pod"), :removebench, false, false, 1)),
    "shapeshifter" => Card("Shapeshifter", 2, "outerspace", "A"),
    "ai"           => Card("A.I.", 2, "outerspace", "A", frombench = (Selector(power = 2), false, 1)),
    "cow"          => Card("Cow", 3, "outerspace", "A"),
    "band"         => Card("Band", 3, "outerspace", "B", frombench = (Selector(set = "outerspace"), false, 1)),
    "ufo"          => Card("Ufo", 3, "outerspace", "B", onplay = (Selector(origin = "A"), :putunderdeck, false, false, 2)),
    "clones"       => Card("Clones", 4, "outerspace", "B"),
    "alien"        => Card("Alien", 5, "outerspace", "B"),
    "hologram"     => Card("Hologram", 4, "outerspace", "C", onplay = (Selector(origin = "B"), :putondeck, true, false, 1)),
    "scifigeek"    => Card("Sci-fi Geek", 6, "outerspace", "C"),
    "slime"        => Card("Slime", 7, "outerspace", "C"),
)

const shipwreck = Dict(
    "merman"    => Card("Merman", 1, "shipwreck", "A", ongoing = (Selector(set = "shipwreck"), :atleast, false, false, 3)),
    "treasure"  => Card("Treasure", 2, "shipwreck", "A", ongoing = (Selector(), :none, false, true, 2)),
    # "sailor"    => Card("Sailor", 2, "shipwreck", "A", onplay = ), # lookat
    "parrot"    => Card("Parrot", 3, "shipwreck", "A"),
    # "cook"      => Card("Cook", 2, "shipwreck", "B", frombench = (Selector(), false, 1)), # card in flag possession
    "lifeguard" => Card("Lifeguard", 4, "shipwreck", "B", ongoing = (Selector(), :deck, false, false, 2)),
    # "navigator" => Card("Navigator", 4, "shipwreck", "B", flagloss = ), # lookat
    "shark"     => Card("Shark", 5, "shipwreck", "B"),
    # "siren"     => Card("Siren", 6, "shipwreck", "C", onplay = (Selector(), :removebench, true, false, 1)),
    "kraken"    => Card("Kraken", 7, "shipwreck", "C"),
    "submarine" => Card("Submarine", 9, "shipwreck", "C", onplay = (Selector(), :removebottom, false, false, 1)),
);

const allcards = reduce(vcat, collect.(values.([starter, city, castle, filmstudio, funfair, hauntedhouse, outerspace, shipwreck])));
const Acards = filter(c -> c.origin == "A", allcards)
const Bcards = filter(c -> c.origin == "B", allcards)
const Ccards = filter(c -> c.origin == "C", allcards)
const Scards = filter(c -> c.origin == "S", allcards);

function makepile(cards)
    pile = Card[]
        for card in cards
            n = if card.name in ["Pig", "Horse", "Talent", "Dog", "Cat", "Lion", "Pony", "Rubber Duck", 
                                 "Spider", "Bat", "Cow", "Alien", "Parrot", "Shark"]
                3
            elseif card.name in ["Dragon", "Champion", "T-Rex", "Teddy Bear", "Werewolf", "Slime", "Kraken"]
                2
            elseif card.name == "Skeleton"
                8
            else
                4
            end
            for i in 1:n
                push!(pile, card)
            end
        end
    pile
end