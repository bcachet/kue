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
		mode:   int | *0o400
	}
	if type == "env" {
		name!: string
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

	initialDelaySeconds: int & >=0 | *1
	periodSeconds:       int & >=1 | *10
	timeoutSeconds:      int & >=1 | *1
	successThreshold:    int & >=1 | *1
	failureThreshold:    int & >=1 | *3

	if type == "http" {
		path!:   string
		scheme: *"HTTP" | "HTTPS"
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
}

#ProbeHttp: #Probe & {
	type: "http"
}

#ProbeGrpc: #Probe & {
	type: "grpc"
}

#ProbeTcp: #Probe & {
	type: "tcp"
}

#ProbeExec: #Probe & {
	type: "exec"
}
