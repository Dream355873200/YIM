# 全栈拉起 (机器重启后): 基础设施依赖 docker compose + 本地 etcd。
# 服务全部走 env: Redis 6380 (Docker 映射), Kafka 9092。
$env:YIM_REDIS_ADDR="127.0.0.1:6380"
$env:YIM_KAFKA_BROKERS="127.0.0.1:9092"
$W="E:\YIM"
Start-Process -FilePath "$W\bin\yim-seq.exe"      -WorkingDirectory $W -WindowStyle Hidden
Start-Process -FilePath "$W\bin\yim-logic.exe"    -WorkingDirectory $W -WindowStyle Hidden
Start-Process -FilePath "$W\bin\yim-relation.exe" -WorkingDirectory $W -WindowStyle Hidden
Start-Process -FilePath "$W\bin\yim-message.exe"  -WorkingDirectory $W -WindowStyle Hidden
Start-Process -FilePath "$W\bin\yim-job.exe"      -WorkingDirectory $W -WindowStyle Hidden
Start-Process -FilePath "$W\bin\yim-comet.exe"    -WorkingDirectory $W -WindowStyle Hidden
Start-Process -FilePath "$W\bin\yimd.exe"         -WorkingDirectory $W -WindowStyle Hidden
Start-Sleep -Seconds 4
