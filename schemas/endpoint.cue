package schemas

#Endpoint: {
	port!:         >0 & <=65535
	containerPort: (>0 & <=65535) | *port
	certificate?:  #Certificate
}

#Certificate: {
	commonName!: string
	altNames?:   [...string]
	pki?:        string
}
