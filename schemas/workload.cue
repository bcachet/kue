package schemas

import (
	core "cue.dev/x/k8s.io/api/core/v1"
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
    image!:   #Image
    command?: [...string]
	args?:    [...string]
    env?:     [string]: #Env
    probes:   [#ProbeType]: core.#Probe
    configs:  [string]: #Config
	volumes:  [string]: #Volume
}

#Env: {
	type!: string | "secret" | "static"
	if type == "secret" {
		kv!: string
	}
}

#EnvStatic: #Env & {
	type: "static"
}

#EnvSecret: #Env & {
	type: "secret"
}

#Image: {
	registry: string | "docker.io" | *"ghcr.io" | "quay.io"
	name!:    string
	tag:      string | *"latest"
}

#Volume: {
	type!: "ephemeral" | "persistent" | "bind" | "secret"
    mount!: string
    mode:   int | *0o400

    if type == "bind" {
        source!: string
    }

	if type == "secret" {
		path!: string
		engine: string | *"kv"
		template?: string
	}
}

#VolumeEphemeral: #Volume & {
    type: "ephemeral"
}

#VolumePersistent: #Volume & {
    type: "persistent"
}

#VolumeBind: #Volume & {
    type: "bind"
}

#VolumeSecret: #Volume & {
	type: "secret"
}

#Config: {
    data!: string | bytes
    mount!: string
}

#Endpoint: {
    port!: int
    containerPort: int | *port
    certificate: #Certificate
}

#Certificate: {
    commonName!: string
    altNames?: [...string]
    pki?: string
}

#ProbeType: "liveness" | "readiness" | "startup"

