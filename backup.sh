echo "Backing up dotfiles"
git add -A
git commit -m "Backup"
git push

echo "Backing up secrets"
cd ./home/secrets
git add -A
git commit -m "Backup"
git push
