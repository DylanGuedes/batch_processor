#!/bin/bash
docker-compose exec data-processor sh -c "MIX_ENV=test mix test --cover"
