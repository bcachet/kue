package backends

import (
	"list"
	"github.com/bcachet/kue/schemas"
	"github.com/bcachet/kue/workloads"
	"github.com/bcachet/kue/backends/klars"
)

manifests: {
	for k, _ in schemas.#Workloads & workloads.workloads {
		"\(k)": {
			kind:       "List"
			apiVersion: "v1"
			items:      list.Concat([[klars.daemonsets[k]], klars.configMaps[k]])
		}
	}
}
