#!/bin/bash
docker-compose exec batch-processor sh -c "MIX_ENV=test mix test"
