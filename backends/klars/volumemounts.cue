package klars

import (
	"path"
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"

	core "cue.dev/x/k8s.io/api/core/v1"
)

volumeMounts: {
	for k, workload in schemas.#Workloads & workloads.workloads
	let _container = workload.container {
		"\(k)": [
			for kv, volume in _container.volumes
			if volume["secret"] == _|_ {
				core.#VolumeMount & {
					name:      "\(k)_vol_\(kv)"
					mountPath: path.Dir(volume.mountPath)
				}
			},
			for kc, config in _container.configs {
				core.#VolumeMount & {
					name:      "\(k)_cfg_\(kc)"
					mountPath: path.Dir(config.mountPath)
				}
			}
		]
	}
}
