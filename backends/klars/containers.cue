package klars

import (
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"

	core "cue.dev/x/k8s.io/api/core/v1"
)

containers: {
	for k, workload in schemas.#Workloads & workloads.workloads
	let _container = workload.container
	let _envs = envs[k]
	let _volumeMounts = volumeMounts[k] {
		"\(k)": core.#Container & {
			name:         k
			image:        images[k]
			env:          _envs
			volumeMounts: _volumeMounts
			for kp, probe in _container.probes {
				"\(kp)Probe": probe
			}
			if _container.resources != _|_ {
				resources: _container.resources
			}
			if _container.security != _|_ {
				securityContext: _container.security
			}
		}
	}
}
