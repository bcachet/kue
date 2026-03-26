package schemas

import resource "cue.dev/x/k8s.io/apimachinery/pkg/api/resource"

#Volume: {
	mountPath!: string
	...
}

#VolumeBind: #Volume & {
	source!: string
}

#VolumeSecret: #Volume & {
	secret: #Secret
}

#VolumeEphemeral: #Volume & {
	sizeLimit: resource.#Quantity | *5Mi
}
