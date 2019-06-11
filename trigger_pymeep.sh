#!/bin/bash

# The local directory where this script and COMMIT_FILENAME are located
CRON_DIR=$HOME/cron
# The local directory where you have checkout out Simpetus/pymeep-nightly-recipe.git
RECIPE_DIR=$HOME/recipes
# The name of your private Github ssh key (assumed to be stored at $HOME/.ssh/)
GITHUB_SSH_PRIVATE_KEY_NAME=id_rsa
# The name of the file that holds the most recent NanoComp/pymeep.git commit hash
COMMIT_FILENAME=latest_pymeep_commit.txt
COMMIT_PATH=${CRON_DIR}/${COMMIT_FILENAME}

# Configure passwordless git
eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/${GITHUB_SSH_PRIVATE_KEY_NAME}

LAST_KNOWN_COMMIT=$(head -n 1 ${COMMIT_PATH})
LATEST_COMMIT=$(git ls-remote git://github.com/NanoComp/pymeep.git refs/heads/master | cut -f 1)

if [ "${LAST_KNOWN_COMMIT}" != "${LATEST_COMMIT}" ]; then
    # Bumb the recipe buildnumber, which will trigger a rebuild on travis,
    # which will publish a new conda package
    pushd ${RECIPE_DIR}/pymeep-nightly-recipe
    git checkout master
    git pull origin master
    sed -r -i 's/(.*set buildnumber = )([0-9]+)(.*)/echo "\1$((\2+1))\3"/ge' recipe/meta.yaml
    git add recipe/meta.yaml
    git commit -m "Cron: Update build number"
    git push origin master
    popd

    echo "Updated build number"

    # Update commit file
    rm ${COMMIT_PATH}
    echo "${LATEST_COMMIT}" > ${COMMIT_PATH}
else
    echo "No updates"
fi
