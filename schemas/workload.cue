package schemas

#Workloads: [Name=string]: #Workload & {
	name: Name
}

#Workload: {
	name!:      string
	container!: #Container
	endpoints?: [...#Endpoint]
}

#Container: {
    image!:   #Image
    command?: [...string]
	args?:    [...string]
    env?:     [string]: string
    probes:   [#ProbeType]: #Probe
    configs:  [string]: #Config
	secrets:  [string]: #Secret
	volumes:  [string]: #Volume
}

#Image: {
	registry: string | "docker.io" | *"ghcr.io" | "quay.io"
	name!:    string
	tag:      string | *"latest"
}

#Volume: {
    mount!: string
    type!: "ephemeral" | "persistent" | "bind"
    if type == "bind" {
        source!: string
    }

}

#VolumeEphemeral: #Volume & {
    type: "ephemeral"
}

#VolumePersistent: #Volume & {
    type: "persistent"
}

#VolumeBind: #Volume & {
    type: "bind"
}

#Secret: {
    path!:     string
	type!:     "env" | "file"
	template?: string
	if type == "file" {
		mount!:  string
		mode?:   int | *0o400
	}
    engine:    string | *"kv"
}

#SecretEnv: #Secret & {
	type: "env"
}

#SecretFile: #Secret & {
	type: "file"
}


#Config: {
    data!: string | bytes
    mount!: string
}

#Endpoint: {
    port!: int
    containerPort: int | *port
    certificate: #Certificate
}

#Certificate: {
    commonName!: string
    altNames?: [...string]
    pki?: string
}

#ProbeType: "liveness" | "readiness" | "startup"

#Probe: {
    type!: "http" | "tcp" | "grpc" | "exec"

    if type != "exec" {
	    port: int
	}

	if type == "http" {
		path!:   string
		scheme?: *"HTTP" | "HTTPS"
		httpHeaders?: [...{
			name:  string
			value: string
		}]
	}

	if type == "grpc" {
		service?: string
	}

	if type == "exec" {
		command!: [...string]
	}

	initialDelaySeconds?: int & >=0 | *0
	periodSeconds?:       int & >=1 | *10
	timeoutSeconds?:      int & >=1 | *1
	successThreshold?:    int & >=1 | *1
	failureThreshold?:    int & >=1 | *3
}
