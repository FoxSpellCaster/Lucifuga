extends Node

var prefixes = ["Shadow", "Moon", "Night", "Gloom", "Mist", "Void", "Dusk", "Crypt", "Raven", "Eclipse"]
var adjectives = ["Haunted", "Eternal", "Spectral", "Mystic", "Crimson", "Silent", "Wraith", "Ancient", "Bleak", "Fell"]
var nouns = ["Haven", "Realm", "Abyss", "Sanctum", "Lair", "Grove", "Shrine", "Depth", "Cairn", "Veil"]
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func generate_lobby_name() -> String:
	var prefix = prefixes[rng.randi_range(0, prefixes.size() - 1)]
	var adjective = adjectives[rng.randi_range(0, adjectives.size() - 1)]
	var noun = nouns[rng.randi_range(0, nouns.size() - 1)]
	return prefix + adjective + noun

func generate_constrained_lobby_name(max_length: int = 32) -> String:
	var name = generate_lobby_name()
	while name.length() > max_length:
		name = generate_lobby_name()
	return name
