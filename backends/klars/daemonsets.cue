package klars

import apps "cue.dev/x/k8s.io/api/apps/v1"

daemonsets: {
	for k, _ in _workloads {
		"\(k)": apps.#DaemonSet & {
			metadata: name: *k | string
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
