## Создать Docker
### Вписать в него:
```Dockerfile
FROM ubuntu:latest
WORKDIR /app
COPY mainscript.sh script_proc.sh /app/
RUN chmod +x mainscript.sh script_proc.sh
```
docker build -t image .

docker run -it image
