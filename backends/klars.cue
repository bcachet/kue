package backends

import (
	"list"
	"path"
	"github.com/bcachet/kue/workloads"
	"github.com/bcachet/kue/schemas"

	apps "cue.dev/x/k8s.io/api/apps/v1"
	core "cue.dev/x/k8s.io/api/core/v1"
)

_workloads: schemas.#Workloads & workloads.workloads

images: {
	for k, workload in _workloads
	let _image = workload.container.image {
		"\(k)": *"\(_image.registry)/\(_image.name):\(_image.tag)" | string
	}
}

_defaultEnvs: {
	for k, workload in _workloads {
		"\(k)": [
			{
				name: "HOSTNAME"
				valueFrom: fieldRef: fieldPath: "spec.nodeName"
			},
		]
	}
}

configMaps: {
	for k, workload in _workloads {
		"\(k)": [
			for kc, config in workload.container.configs {
				core.#ConfigMap & {
					metadata: name: "\(k)_\(kc)"
					data: {
						"\(path.Base(config.mount, path.Unix))": config.data
					}
				}
			}
		]
	}
}

envs: {
	for k, workload in _workloads
	let _envs = workload.container.envs {
		"\(k)": [
			for ke, env in _envs
			if env["secret"] == _|_ {
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
	for k, workload in _workloads
	let _container = workload.container {
		"\(k)": [
			for kv, volume in _container.volumes 
			if volume["secret"] == _|_ {
				core.#VolumeMount & {
					name:      "\(k)_vol_\(kv)"
					mountPath: path.Dir(volume.mount)
				}
			},
			for kc, config in _container.configs {
				core.#VolumeMount & {
					name: "\(k)_cfg_\(kc)"
					mountPath: path.Dir(config.mount)
				}
			}
		]
	}
}

volumes: {
	for k, workload in _workloads
	let _container = workload.container {
		"\(k)": list.Concat([
			[for kc, config in _container.configs {
				core.#Volume & {
					name: "\(k)_cfg_\(kc)"
					configMap: name: "\(k)_\(kc)"
				}
			}],
			[for kv, volume in _container.volumes
			 if volume["secret"] == _|_ {
				core.#Volume & {
					name: "\(k)_vol_\(kv)"
					if volume["source"] != _|_ {
						hostPath: {
							path: volume.source
						}
					}
					if volume["source"] == _|_ {
						emptyDir: {
							medium: "Memory"
						}
					}
				}
			}]
		])
	}
}

containers: {
	for k, workload in _workloads
	let _container = workload.container
	let _volumeMounts = volumeMounts[k] {
		"\(k)": core.#Container & {
			name:  *k | string
			image: *images[k] | string
			env: [
				for env in envs[k]
				if env.secret == _|_ {
					env
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
	for k, workload in _workloads
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

daemonsets: {
	for k, workload in _workloads {
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

manifests: {
	for k, workload in _workloads {
		"\(k)": {
			kind: "List"
			apiVersion: "v1"
			items: list.Concat([[daemonsets[k]], configMaps[k]])
		}
	}
}
