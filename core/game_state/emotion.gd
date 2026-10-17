class_name Emotion extends RefCounted
## Семь состояний лица героя.

enum Kind { JOY, MEMORY, WORRY, FEAR, DOUBT, SAD, OFF }

const NAMES: Dictionary = {
	Kind.JOY: "joy",
	Kind.MEMORY: "memory",
	Kind.WORRY: "worry",
	Kind.FEAR: "fear",
	Kind.DOUBT: "doubt",
	Kind.SAD: "sad",
	Kind.OFF: "off",
}


static func key(kind: Kind) -> String:
	return NAMES[kind]
