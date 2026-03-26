package klars

import (
    "path"
    "github.com/bcachet/kue/schemas"
    "github.com/bcachet/kue/workloads"

    core "cue.dev/x/k8s.io/api/core/v1"
)

configMaps: {
	for k, workload in schemas.#Workloads & workloads.workloads {
		"\(k)": [
			for kc, config in workload.container.configs {
				core.#ConfigMap & {
					metadata: name: "\(k)_\(kc)"
					data: {
						"\(path.Base(config.mountPath, path.Unix))": config.data
					}
				}
			}
		]
	}
}