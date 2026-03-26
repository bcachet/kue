package workloads

import (
	"encoding/json"
	schemas "github.com/bcachet/kue/schemas:schemas"
)

workloads: schemas.#Workloads & {
	redis: {
		container: {
			image: name: "redis"
			probes: liveness: {
				httpGet: {
					port: 6379
				}
			}
			configs: redis: {
				data: json.Marshal(
					{
						foo: "bar"
					})
				mount: "/etc/redis/redis.json"
			}
			volumes: {
				data: {
					mount: "/data"
				}
				creds: {
					path:  "redis/password"
					mount: "/run/secrets/redis_password"
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
					path: "my/secret"
				}
			}
			resources: {
				limits: {
					cpu:    3
					memory: 1.5Gi
				}
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
