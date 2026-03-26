package schemas

#Image: {
	registry: "docker.io" | *"ghcr.io" | "quay.io"
	name!:    string
	tag:      string | *"latest"
}
