package klars

import (
	"list"
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"

	core "cue.dev/x/k8s.io/api/core/v1"
)

volumes: {
	for k, workload in schemas.#Workloads & workloads.workloads
	let _container = workload.container {
		"\(k)": list.Concat([
			[for kc, config in _container.configs {
				core.#Volume & {
					name:      "\(k)_cfg_\(kc)"
					configMap: name: "\(k)_\(kc)"
				}
			}],
			[for kv, volume in _container.volumes
			 if volume["secret"] == _|_ {
				core.#Volume & {
					name: "\(k)_vol_\(kv)"
					if volume["source"] != _|_ {
						hostPath: path: volume.source
					}
					if volume["source"] == _|_
					let _volume = schemas.#VolumeEphemeral & volume {
						emptyDir: {
							medium:    "Memory"
							sizeLimit: _volume.sizeLimit
						}
					}
				}
			}]
		])
	}
}
