
## Dev

1. Clone the repository
2. Create a `.env` file based on `.env.template`
3. Run the command `git submodule update --init --recursive` to initialize and rebuild the submodules
4. Run the command `docker compose up --build`


### Steps to create Git Submodules

1. Create a new repository on GitHub
2. Clone the repository to your local machine
3. Add the submodule, where `repository_url` is the repository URL and `directory_name` is the folder name where you want to store the submodule (it must not already exist in the project)
```
git submodule add <repository_url> <directory_name>
```
4. Add the changes to the repository (git add, git commit, git push)  
Example:
```
git add .
git commit -m "Add submodule"
git push
```
5. Initialize and update submodules. When someone clones the repository for the first time, they must run the following command:
```
git submodule update --init --recursive
```
6. To update submodule references:
```
git submodule update --remote
```


## Important

If you are working in a repository that contains submodules, **first update and push** the submodule, and **then** update and push the main repository.

If you do it the other way around, submodule references in the main repository may be lost, and you will need to resolve conflicts.