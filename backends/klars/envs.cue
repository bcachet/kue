package klars

import (
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"

	core "cue.dev/x/k8s.io/api/core/v1"
)

envs: {
	for k, workload in schemas.#Workloads & workloads.workloads
	let _containerEnvs = workload.container.envs
	let _defaultEnvs = {hostname: {valueFrom: "spec.nodeName"}}
	let _allEnvs = _defaultEnvs & _containerEnvs {
		"\(k)": [
			for ke, env in _allEnvs
			if env["secret"] == _|_ {
				core.#EnvVar & {
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
