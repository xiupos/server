# pgdb-init

## vars

- `PGHOST`
- `PGUSER`
- `PGPASSWORD`
- `APP_DB_NAME`
- `APP_DB_USER`
- `APP_DB_PASS`

## Example

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-init-example
  namespace: postgres-common
spec:
  ttlSecondsAfterFinished: 60
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: db-init
          image: ghcr.io/xiupos/pgdb-init:latest
          env:
            - name: PGHOST
              value: "db-rw"
            - name: PGUSER
              valueFrom:
                secretKeyRef:
                  name: db-superuser
                  key: username
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-superuser
                  key: password
            - name: APP_DB_NAME
              value: "example_db"
            - name: APP_DB_USER
              value: "example_user"
            - name: APP_DB_PASS
              value: "example_pass"
```
