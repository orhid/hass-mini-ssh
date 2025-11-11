#!/usr/bin/env bash
export SUPERVISOR_TOKEN={{ .supervisor_token }}

# ha banner
# shellcheck disable=SC1090
source <(ha completion bash)
