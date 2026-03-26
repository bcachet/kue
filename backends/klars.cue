package backends

import (
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

containers: {
	for k, workload in workloads.workloads {
		"\(k)": core.#Container & {
			name:  *k | string
			image: *images[k] | string
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
