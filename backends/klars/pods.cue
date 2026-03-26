package klars

import core "cue.dev/x/k8s.io/api/core/v1"

pods: {
	for k, _ in _workloads
	let _containers = [containers[k]]
	let _volumes = volumes[k] {
		"\(k)": core.#PodSpec & {
			serviceAccountName: *k | string
			hostNetwork:        *true | bool
			containers:         _containers
			volumes:            _volumes
		}
	}
}
