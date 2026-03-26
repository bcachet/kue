package klars

import (
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"

	apps "cue.dev/x/k8s.io/api/apps/v1"
)

daemonsets: {
	for k, _ in schemas.#Workloads & workloads.workloads {
		"\(k)": apps.#DaemonSet & {
			metadata: name: *k | string
			spec: apps.#DaemonSetSpec & {
				selector: matchLabels: name: *k | string
				template: {
					metadata: {
						labels:      {}
						annotations: {}
					}
					spec: pods[k]
				}
			}
		}
	}
}
