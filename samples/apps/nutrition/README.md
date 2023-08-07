 ## Install NATS

 ```bash
 helm install nats nats/nats \
--namespace=nats \
--create-namespace=true \
--set nats.jetstream.enabled=true \
--set nats.jetstream.memStorage.enabled=true \
--set nats.jetstream.memStorage.size=1Gi \
--set nats.jetstream.fileStorage.enabled=true \
--set nats.jetstream.fileStorage.size=1Gi \
--set nats.jetstream.fileStorage.storageDirectory=/data/
 ```


 curl --location --request POST '0.0.0.0:8080/calculator' \
--header 'Content-Type: application/json' \
--data-raw '{ 
   "age": 26,
   "weight": 90.0,
   "height": 1.77,
   "gender": "M", 
   "activity_intensity": "very_active"
} ' --silent | jq .