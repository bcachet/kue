package klars

import (
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"

	core "cue.dev/x/k8s.io/api/core/v1"
)

pods: {
	for k, _ in schemas.#Workloads & workloads.workloads
	let _containers = [containers[k]]
	let _volumes = volumes[k] {
		"\(k)": core.#PodSpec & {
			serviceAccountName: *k | string
			hostNetwork:        *true | bool
			containers: _containers
			volumes:    _volumes
		}
	}
}
