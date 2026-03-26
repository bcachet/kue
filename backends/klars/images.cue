package klars

images: {
	for k, workload in _workloads
	let _image = workload.container.image {
		"\(k)": *"\(_image.registry)/\(_image.name):\(_image.tag)" | string
	}
}
