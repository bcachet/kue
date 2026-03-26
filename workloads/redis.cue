package workloads

import (
	"encoding/json"
	schemas "github.com/bcachet/kue/schemas:schemas"
)

workloads: schemas.#Workloads & {
	redis: schemas.#Workload & {
		container: {
			image: name: "redis"
			probes: liveness: {
				httpGet: {
					port: 6379
				}
			}
			configs: redis: schemas.#Config & {
				data: json.Marshal(
					{
						foo: "bar"
					})
				mount: "/etc/redis/redis.json"
			}
			volumes: {
				data: schemas.#VolumePersistent & {
					mount: "/data"
				}
				creds: schemas.#VolumeSecret & {
					path:  "redis/password"
					mount: "/run/secrets/redis_password"
				}
			}
            envs: [
                schemas.#EnvVar & {
                    name: "foo"
                    value: "bar"
                },
                schemas.#EnvSecret & {
                    name: "key"
                    path: "kv/key"
                },
            ]
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
