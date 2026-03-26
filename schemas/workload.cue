package schemas

#Workloads: [string]: #Workload

#Workload: {
	container!: #Container
	endpoints?: [...#Endpoint]
}
