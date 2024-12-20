$branch = ""

# Create a new branch
git branch $branch
git checkout $branch

# Stage/Commit/Push
$commitMessage = ""
git add .
git commit -m $commitMessage
git push --set-upstream origin $branch

# Cleanup
git checkout main
git fetch --prune
git pull
git branch -D $branch
