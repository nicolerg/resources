# Minimal `git` primer  
**Using `git` to work with GitHub from the command line** 

These are the most important steps to get started! `git` is pretty helpful in terms of giving you descriptive error messages to prevent you from doing anything too destructive. And besides, the great thing about `git` is that you can revert to a previous version of the code even if some disastrous change is made!  

This documentation shows only the simplest usage for each of these `git` commands. Many other more detailed tutorials are available online.  

All of these steps can also be done directly on GitHub, but this documentation is specifically for `git`. 

### 0. A little jargon 
- The **`remote`** repository is the version on GitHub, i.e. https://github.com/MoTrPAC/motrpac-mawg.  
- The **`local`** repository is the copy you make when you `clone` the remote repository.  
- **`Branches`** refer to different parallel versions of the repository. 
- The **`master`** branch is the "master" version of the repository that is shown by default on https://github.com/MoTrPAC/motrpac-mawg.  

### 1. Clone the repository  
"Clone" means make a local copy of the repository. Navigate to the folder where you want to clone the repo. It will be added in a new folder, where the folder name is the name of the repository (`motrpac-mawg` in this case). 
```bash
git clone https://github.com/MoTrPAC/motrpac-mawg.git
```

### 2. Add changes 

#### 2.0 *Optional:* Create a new local branch before making changes  
This is particularly useful if you want to isolate ongoing subprojects in separate branches, e.g. clustering versus differential analysis. In this example, the new branch is called `my_analysis`. The `-b` flag indicates you want to create a *new* local branch:   
```bash
git checkout -b my_analysis
```
To list all of your local branches, use `git branch`. To switch between branches, use `git checkout [branch-name]`. 

#### 2.1 Add new files 
Use your favorite text editor to add and edit files in your local branch. To add *all* new files you've added to your local copy of `motrpac-mawg`, navigate to any subfolder within `motrpac-mawg` and use:
```bash
git add -A :/
```

#### 2.2. Commit changes  
This is the essentially the "save your work" command. To save *all* new changes you have made, use: 
```bash
git commit -a -m "fig 1c analysis"
```
The `-m` flag is used to annotate your commit with a brief message.  

### 3. Push your local branch to the `motrpac-mawg` repository
Until you `push` your local commits to the remote repository, no one else can see your code. To push your changes/additions to a branch called `nicolerg_analysis` viewable on https://github.com/MoTrPAC/motrpac-mawg, run:
```bash
git push origin nicolerg_analysis
```

And that's it to get started! Continue to edit your code locally and push new changes to the remote branch you made in Step 3. Feel free to reach out if you have questions. 
