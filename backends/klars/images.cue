package klars

import (
    "github.com/bcachet/kue/schemas"
    "github.com/bcachet/kue/workloads"
)

images: {
	for k, workload in schemas.#Workloads & workloads.workloads
	let _image = schemas.#Image & workload.container.image {
		"\(k)": *"\(_image.registry)/\(_image.name):\(_image.tag)" | string
	}
}