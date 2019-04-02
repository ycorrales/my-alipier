#!/bin/bash -e

set -o pipefail
cd "$(dirname "$0")"

# Travis CI fold and timing
# See http://www.garbers.co.za/2017/11/01/code-folding-and-timing-in-travis-ci/
function fold_start() {
  if [[ $CURRENT_SECTION ]]; then
    fold_end
  fi
  CURRENT_SECTION=$(echo "$1" | sed -e 's![^A-Za-z0-9\._]!_!g')
  if [[ $TRAVIS == true ]]; then
    travis_fold start "$CURRENT_SECTION"
    travis_time_start
  fi
  echo -e "\033[34;1m$2\033[m"
}

function fold_end() {
  if [[ $TRAVIS == true ]]; then
    travis_time_finish
    travis_fold end "$CURRENT_SECTION"
  fi
  CURRENT_SECTION=
}

function fatal() {
  echo -e "\033[31;1m$1\033[m"
  exit 1
}

DOCKER_ORG=alipier
EXPECTED_HELLO_WORLD='hello, world!'

if [[ $RANGE ]]; then
  # Range manually set
  DOCKER_PUSH=
elif [[ $TRAVIS_PULL_REQUEST != false && $TRAVIS_COMMIT_RANGE ]]; then
  # We are testing a Pull Request: do not push
  DOCKER_PUSH=
  RANGE="$TRAVIS_COMMIT_RANGE"
elif [[ $TRAVIS_PULL_REQUEST == false && $TRAVIS_BRANCH == master ]]; then
  # We are testing the master branch (e.g. when PR is merged)
  DOCKER_PUSH=1
  RANGE="HEAD^"
fi

# Load Docker Hub user and password
if [[ $DOCKER_PUSH ]]; then
  fold_start docker_login "Login to Docker"
    docker login -u "$(eval echo \$DOCKER_USER_${DOCKER_ORG})" \
                 -p "$(eval echo \$DOCKER_PASS_${DOCKER_ORG})"
  fold_end
fi

# Gather list of what's changed
fold_start list_changed "List of changed files and related symlinks"
  CHANGED=( $(git diff --name-only $RANGE | (grep / || true) | cut -d/ -f1,2 | sort -u) )

  # Find all symlinks pointing to the changed containers
  while read SYMLINK; do
    SYMDEST=$(realpath "$SYMLINK")     # resolve path
    SYMDEST=${SYMDEST:$((${#PWD}+1))}  # make it relative to cwd
    for CH in "${CHANGED[@]}"; do
      if [[ $CH == $SYMDEST ]]; then
        CHANGED+=("$SYMLINK")
      fi
    done
  done < <(find . -type l | sed -e 's!^\./!!')

  CHANGED=( $(for CH in "${CHANGED[@]}"; do echo "$CH"; done | sort -u) )  # remove dups

  for CH in "${CHANGED[@]}"; do
    echo "* $CH"
  done
fold_end

for DOCK in "${CHANGED[@]}"; do
  # Rebuild all containers that changed, and check if they work with alidock
  [[ -d $DOCK && ! -L $DOCK ]] || continue
  pushd "$DOCK" &> /dev/null
    DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"

    fold_start docker_build "Build Docker image $DOCKER_IMAGE"
      $DRY_PREFIX docker build . -t "$DOCKER_IMAGE"
    fold_end

    fold_start alidock_exec "Test alidock with $DOCKER_IMAGE"
      $DRY_PREFIX alidock stop
      HELLO_WORLD=$($DRY_PREFIX alidock --no-update-image --image "$DOCKER_IMAGE" exec /bin/echo -n "$EXPECTED_HELLO_WORLD" | tail -n1)
      if [[ "$HELLO_WORLD" != "$EXPECTED_HELLO_WORLD" && ! $DRY_PREFIX ]]; then
        fatal "Container $DOCKER_IMAGE seems not to be usable with $(alidock --version)"
      fi
    fold_end

    if [[ $DOCKER_PUSH ]]; then
      fold_start docker_push "Push Docker image $DOCKER_IMAGE"
        docker push "$DOCKER_IMAGE"
      fold_end
    fi
  popd &> /dev/null
done

for DOCK in "${CHANGED[@]}"; do

  # Repush/check all symlinks that changed
  [[ -L $DOCK ]] || continue

  fold_start dock_symlink "Test Docker image symlink $DOCK"
    # Check if the link points to something existing
    if [[ ! -d $DOCK ]]; then
      fatal "Symbolic link $DOCK does not point to a valid tag from the same repo: $(readlink $DOCK)"
    fi
    # Sanitize: strip final slashes from original tag
    DOCKER_IMAGE_ORIG=$DOCKER_ORG/$(dirname "$DOCK"):$(readlink "$DOCK" | sed -e 's!/*$!!g')
    # Validate tag name
    DOCKER_TAG=$(basename "$DOCK")
    if [[ ! $DOCKER_TAG =~ ^[A-Za-z0-9_][A-Za-z0-9\._-]*$ || ${#DOCKER_TAG} -gt 128 ]]; then
      fatal "Format of Docker tag $DOCKER_TAG is invalid"
    fi
    DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"
  fold_end

  fold_start docker_tag "Retag Docker image $DOCKER_IMAGE to $DOCKER_IMAGE_ORIG"
    if [[ $DOCKER_PUSH ]]; then
        docker pull "$DOCKER_IMAGE_ORIG"
        docker tag "$DOCKER_IMAGE_ORIG" "$DOCKER_IMAGE"
        docker push "$DOCKER_IMAGE"
    else
      echo "Link tag validated: $DOCKER_IMAGE -> $DOCKER_IMAGE_ORIG"
    fi
  fold_end

done
