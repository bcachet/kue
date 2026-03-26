package schemas

import (
	core "cue.dev/x/k8s.io/api/core/v1"
	resource "cue.dev/x/k8s.io/apimachinery/pkg/api/resource"
)

#Workloads: [Name=string]: #Workload & {
	name: Name
}

#Workload: {
	name!:      string
	container!: #Container
	endpoints?: [...#Endpoint]
}

#Container: {
	image!: #Image
	command?: [...string]
	args?: [...string]
	envs?: [Name=string]: #Env & {
		name: Name
	}
	probes: [#ProbeType]: core.#Probe
	configs: [string]:    #Config
	volumes: [string]:    #Volume
	resources?: core.#ResourceRequirements
	security?: core.#SecurityContext
}

#Env: {
	name!: string
	...
}

#EnvConstant: #Env & {
	value: string
}

#EnvDownward: #Env & {
	valueFrom: string
}

#EnvSecret: #Env & {
	secret: #Secret
}

#Image: {
	registry: string | "docker.io" | *"ghcr.io" | "quay.io"
	name!:    string
	tag:      string | *"latest"
}

#Volume: {
	mount!: string
	mode:   int | *0o400
	...
}

#VolumeBind: #Volume & {
	source!: string
}

#VolumeSecret: #Volume & {
	secret: #Secret
}

#VolumeEphemeral: #Volume & {
	sizeLimit: resource.#Quantity
}

#Secret: {
	kv!:     string
	engine:    string | *"kv"
	template?: string
}

#Config: {
	data!:  string | bytes
	mount!: string
}

#Endpoint: {
	port!:         int
	containerPort: int | *port
	certificate:   #Certificate
}

#Certificate: {
	commonName!: string
	altNames?: [...string]
	pki?: string
}

#ProbeType: "liveness" | "readiness" | "startup"
