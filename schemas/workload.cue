package schemas

#Workloads: [Name=string]: #Workload & {
	name: Name
}

#Workload: {
	name!:      string
	container!: #Container
	endpoints?: [...#Endpoint]
}
