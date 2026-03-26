package schemas

#Secret: {
	kv!:       string
	engine:    string | *"kv"
	template?: string
}
