#!/bin/bash
docker-compose exec batch-processor sh -c "mix ecto.create"
docker-compose exec batch-processor sh -c "mix ecto.migrate"
