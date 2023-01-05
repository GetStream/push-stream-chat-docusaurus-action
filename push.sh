set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email ""
git config --global user.name "$USER_NAME"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$USER_NAME:$DOCUSAURUS_GH_TOKEN@github.com/$DESTINATION_GITHUB_USERNAME/$DESTINATION_REPOSITORY_NAME.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

SDKs=(`find ./$SOURCE_DIRECTORY/docs -maxdepth 1 -mindepth 1 -type d | awk -F'/' '{print $NF}'`)
for sdk in "${SDKs[@]}"
do
    echo "Deleting all contents of $sdk in target git repository and copying current over"
    find $CLONE_DIR/docusaurus -maxdepth 1 -mindepth 1 -type f -iname "*${sdk/ /}*" -exec bash $ACTION_PATH/find_match_handler.sh ${sdk/ /} {} \;
    find $CLONE_DIR/docusaurus -maxdepth 1 -mindepth 1 -type d -iname "*${sdk/ /}*" -exec bash $ACTION_PATH/find_match_handler.sh ${sdk/ /} {} \;
    find $CLONE_DIR/docusaurus -maxdepth 2 -mindepth 2 -type d -iname "*${sdk/ /}*" -exec bash $ACTION_PATH/find_match_handler.sh ${sdk/ /} {} \;
    ls -la $CLONE_DIR/docusaurus
    ls -la $CLONE_DIR/docusaurus/docs
done
cp -a "$SOURCE_DIRECTORY"/. "$CLONE_DIR/docusaurus"

cd "$CLONE_DIR"

ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

# avoid overriding the .env file with the one from the target directory
if [ -f "docusaurus/.env" ]; then
    git checkout "docusaurus/.env"
fi

git add .
git status

# git diff-index : to avoid the git commit failing if there are no changes to be committed
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

# --set-upstream: sets default branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$DOCUSAURUS_GH_TOKEN@github.com/$DESTINATION_GITHUB_USERNAME/$DESTINATION_REPOSITORY_NAME.git" --set-upstream "$TARGET_BRANCH"
