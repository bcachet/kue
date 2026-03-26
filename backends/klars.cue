package backends

import (
	"list"
	"github.com/bcachet/kue/workloads"
	// "github.com/bcachet/kue/schemas"

	apps "cue.dev/x/k8s.io/api/apps/v1"
	core "cue.dev/x/k8s.io/api/core/v1"
)

images: {
	for k, workload in workloads.workloads
	let image = workload.container.image {
		"\(k)": *"\(image.registry)/\(image.name):\(image.tag)" | string
	}
}

envs: {
	for k, workload in workloads.workloads
	let envs = workload.container.envs {
		"\(k)": list.Concat(
			[
				envs,
				[
					{
						name: "HOSTNAME"
						valueFrom: fieldRef: fieldPath: "spec.nodeName"
					},
				],
			],
		)
	}
}

containers: {
	for k, workload in workloads.workloads
	let container = workload.container {
		"\(k)": core.#Container & {
			name:  *k | string
			image: *images[k] | string
			env: [
				for secret in envs[k]
				if secret.path == _|_ {
					secret
				},
			]
			for kp, probe in container.probes {
				"\(kp)Probe": probe
			}
		}
	}
}

pods: {
	for k, workload in workloads.workloads
	let mainPod = containers[k] {
		"\(k)": core.#PodSpec & {
			serviceAccountName: *k | string
			hostNetwork:        *true | bool
			containers: [
				mainPod,
			]
		}
	}
}

manifests: {
	for k, workload in workloads.workloads {
		"\(k)": apps.#DaemonSet & {
			metadata: {
				name: *k | string
			}
			spec: apps.#DaemonSetSpec & {
				selector: matchLabels: name: *k | string
				template: {
					metadata: {
						labels: {}
						annotations: {}
					}
					spec: pods[k]
				}
			}
		}
	}
}
