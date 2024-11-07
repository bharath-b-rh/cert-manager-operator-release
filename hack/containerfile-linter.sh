#!/usr/bin/env bash

declare -a CONTAINERFILES

CERT_MANAGER_OPERATOR_CONTAINERFILES=("Containerfile.cert-manager" "Containerfile.cert-manager.acmesolver" "Containerfile.cert-manager-operator" "Containerfile.cert-manager-operator.bundle")

linter()
{
	containerfiles=("$@")
	for containerfile in "${containerfiles[@]}"; do
		if [[ ! -f "${containerfile}" ]]; then
			echo "[$(date)] -- ERROR -- ${containerfile} does not exist"
			exit 1
		fi
		echo "[$(date)] -- INFO  -- running linter on ${containerfile}"
		if ! podman run --rm -i -e "HADOLINT_FAILURE_THRESHOLD=error" ghcr.io/hadolint/hadolint < "${containerfile}" ; then
			exit 1
		fi
	done
}

containerfile_linter()
{
	if [[ "${#CONTAINERFILES[@]}" -gt 0 ]]; then
		linter "${CONTAINERFILES[@]}"
		return
	fi
	echo "[$(date)] -- INFO  -- running linter on ${CERT_MANAGER_OPERATOR_CONTAINERFILES[*]}"
	linter "${CERT_MANAGER_OPERATOR_CONTAINERFILES[@]}"
}

##############################################
###############  MAIN  #######################
##############################################

if [[ $# -gt 1 ]]; then
	CONTAINERFILES=("$@")
	echo "[$(date)] -- INFO  -- running linter on $*"
fi

containerfile_linter

exit 0
