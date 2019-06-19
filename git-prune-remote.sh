#!/bin/bash

git fetch --prune origin

for branch in $(git branch); do

  origin=$(git config "branch.${branch}.remote")
  if [ -n "$origin" ]; then
    echo $branch remote is $origin
    if ! git branch -r | grep "$origin/$branch" > /dev/null; then
      echo "upstream branch for $branch has been deleted"
      git branch -D "$branch"
    fi
  fi

done

