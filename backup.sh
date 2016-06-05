echo "Backing up dotfiles"
git add -A
git commit -m "Backup"
git push

echo "Backing up secure files"
cd ~/secure
git add -A
git commit -m "Backup"
git push
