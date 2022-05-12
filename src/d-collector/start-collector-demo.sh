#!/bin/bash

version=$(dotnet gitversion /output json /showvariable InformationalVersion)

tmux new-session -d 'docker run -it --rm --network demo_default -p 4317:4317 -v $PWD/otel-collector-config.yaml:/etc/otel/config.yaml otel/opentelemetry-collector-contrib'

tmux split-window -hbp 67 'ASPNETCORE_URLS="http://localhost:8002" npm run start --prefix Demo.WebApp/ClientApp'
tmux split-window "dotnet run --project Demo.WebApp -p:InformationalVersion=$version -- --urls http://*:8002 --environment Development"
tmux split-window -ht 0 "dotnet run --project Demo.Service -p:InformationalVersion=$version -- --urls https://*:44301 --environment Development"
tmux split-window -ht 2 "dotnet run --project Demo.Worker -p:InformationalVersion=$version -- --environment Development"
tmux attach-session -d
