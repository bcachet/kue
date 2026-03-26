package schemas

#Env: #EnvConstant | #EnvDownward | #EnvSecret

#EnvConstant: {
	value: string
}

#EnvDownward: {
	valueFrom: string
}

#EnvSecret: {
	secret: #Secret
}
