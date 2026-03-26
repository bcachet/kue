package backends

import (
	// "list"
	"github.com/bcachet/kue/workloads"
	// "github.com/bcachet/kue/schemas"

	apps "cue.dev/x/k8s.io/api/apps/v1"
	core "cue.dev/x/k8s.io/api/core/v1"
)

images: {
	for k, workload in workloads.workloads
	let _image = workload.container.image {
		"\(k)": *"\(_image.registry)/\(_image.name):\(_image.tag)" | string
	}
}

_defaultEnvs: {
	for k, workload in workloads.workloads {
		"\(k)": [
			{
				name: "HOSTNAME"
				valueFrom: fieldRef: fieldPath: "spec.nodeName"
			},
		]
	}
}

envs: {
	for k, workload in workloads.workloads
	let _envs = workload.container.envs {
		"\(k)": [
			for ke, env in _envs
			if env["path"] == _|_ {
				{
					name: ke
					if env["value"] != _|_ {
						value: env.value
					}
					if env["valueFrom"] != _|_ {
						valueFrom: fieldRef: fieldPath: env.valueFrom
					}
				}
			},
		]
	}
}

volumeMounts: {
	for k, workload in workloads.workloads
	let _container = workload.container {
		"\(k)": [
			for kv, volume in _container.volumes {
				name:      "\(k)_\(kv)"
				mountPath: volume.mount
			},
			// TODO: Add support for ConfigMap/Secret
		]
	}
}

volumes: {
	for k, workload in workloads.workloads
	let container = workload.container {
		"\(k)": []
	}
}

containers: {
	for k, workload in workloads.workloads
	let _container = workload.container
	let _volumeMounts = volumeMounts[k] {
		"\(k)": core.#Container & {
			name:  *k | string
			image: *images[k] | string
			env: [
				for secret in envs[k]
				if secret.path == _|_ {
					secret
				},
			]
			for kp, probe in _container.probes {
				"\(kp)Probe": probe
			}
			if _container.resources != _|_ {
				resources: _container.resources
			}
			volumeMounts: _volumeMounts
		}
	}
}

pods: {
	for k, workload in workloads.workloads
	let _pod = containers[k]
	let _volumes = volumes[k] {
		"\(k)": core.#PodSpec & {
			serviceAccountName: *k | string
			hostNetwork:        *true | bool
			containers: [
				_pod,
			]
			volumes: _volumes
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
