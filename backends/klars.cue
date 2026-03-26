package backends

import (
	"list"
	"github.com/bcachet/kue/workloads"
	"github.com/bcachet/kue/backends/klars"
)

manifests: {
	for k, _ in workloads.workloads {
		"\(k)": {
			kind:       "List"
			apiVersion: "v1"
			items: list.Concat([[klars.daemonsets[k]], klars.configMaps[k]])
		}
	}
}
