package schemas

import core "cue.dev/x/k8s.io/api/core/v1"

#Container: {
	image!:     #Image
	command?:   [...string]
	args?:      [...string]
	envs?:      [string]: #Env
	probes:     [#ProbeType]: core.#Probe
	configs:    [string]: #Config
	volumes:    [string]: #Volume
	resources?: core.#ResourceRequirements
	security?:  core.#SecurityContext
}
