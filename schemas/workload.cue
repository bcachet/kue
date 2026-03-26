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
	image!:    #Image
	command?:  [...string]
	args?:     [...string]
	envs?:     [string]: #Env
	probes:    [#ProbeType]: core.#Probe
	configs:   [string]: #Config
	volumes:   [string]: #Volume
	resources?: core.#ResourceRequirements
	security?:  core.#SecurityContext
}

#Image: {
	registry: "docker.io" | *"ghcr.io" | "quay.io"
	name!:    string
	tag:      string | *"latest"
}

#Config: {
	data!:  string | bytes
	mountPath!: string
}

#Endpoint: {
	port!:         >0 & <=65535
	containerPort: (>0 & <=65535) | *port
	certificate?:  #Certificate
}

#Certificate: {
	commonName!: string
	altNames?:   [...string]
	pki?:        string
}

#ProbeType: "liveness" | "readiness" | "startup"

#Env: #EnvConstant | #EnvDownward | #EnvSecret

#EnvConstant: {
	value: string
}

#EnvDownward: {
	valueFrom: string
}

#EnvSecret: {
	secret: #Secret
}

#Volume: {
	mountPath!: string
	...
}

#VolumeBind: #Volume & {
	source!: string
}

#VolumeSecret: #Volume & {
	secret: #Secret
}

#VolumeEphemeral: #Volume & {
	sizeLimit:  resource.#Quantity | *5Mi
}

#Secret: {
	kv!:       string
	engine:    string | *"kv"
	template?: string
}
