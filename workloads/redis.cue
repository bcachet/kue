package workloads

import (
	"encoding/json"
)

workloads: {
	redis: {
		container: {
			image: {
				name: "redis"
			}
			configs: redis: {
				data: json.Marshal(
					{
						foo: "bar"
					})
				mountPath: "/etc/redis/redis.json"
			}
			volumes: {
				data: {
					mountPath: "/data"
				}
				creds: {
					secret: {
						kv:    "redis/password"
					}
					mountPath: "/run/secrets/redis_password"
				}
			}
			envs: {
				foo: {
					value: "bar"
				}
				sa: {
					valueFrom: "spec.serviceAccountName"
				}
				"my-secret": {
					secret: {
						kv: "my/secret"
					}
				}
			}
			resources: {
				limits: {
					cpu:    3
					memory: 1.5Gi
				}
			}
			probes: liveness: {
				httpGet: {
					port: 6379
				}
			}
			security: {
				runAsUser: 1394
			}
		}

		endpoints: [
			{
				port: 6379
				certificate: {
					commonName: "redis.default.svc.cluster.local"
					altNames: ["redis", "localhost"]
				}
			},
		]

	}
}
