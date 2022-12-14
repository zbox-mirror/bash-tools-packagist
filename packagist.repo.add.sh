#!/usr/bin/bash -e

(( EUID == 0 )) && { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

curl="$( command -v curl )"
sleep="2"

# Help.
read -r -d '' help <<- EOF
Options:
  -x 'TOKEN'                            Packagist token.
  -u 'USER'                             Packagist user name.
  -r '[URL1;URL2;URL3]'                 Repository URL array.
EOF

# -------------------------------------------------------------------------------------------------------------------- #
# OPTIONS.
# -------------------------------------------------------------------------------------------------------------------- #

OPTIND=1

while getopts "x:u:r:h" opt; do
  case ${opt} in
    x)
      token="${OPTARG}"
      ;;
    u)
      user="${OPTARG}"
      ;;
    r)
      repos="${OPTARG}"; IFS=';' read -ra repos <<< "${repos}"
      ;;
    h|*)
      echo "${help}"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#repos[@]} )) || [[ -z "${user}" ]] && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Run.
  repo_add
}

# -------------------------------------------------------------------------------------------------------------------- #
# PACKAGIST: ADD REPOSITORY.
# -------------------------------------------------------------------------------------------------------------------- #

repo_add() {
  for repo in "${repos[@]}"; do
    echo "" && echo "--- OPEN: '${repo}'"

    ${curl} -X POST \
      -H "Content-Type: application/json" \
      "https://packagist.org/api/create-package?username=${user}&apiToken=${token}" \
      -d "{\"repository\":{\"url\":\"${repo}\"}}"

    echo "" && echo "--- DONE: '${repo}'" && echo ""; sleep ${sleep}
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
