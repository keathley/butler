# How to contribute

Butler is intended to be a community project and Pull requests are greatly appreciated. Here's a guide to help get you started:

1) Fork the repo, clone your fork, and update your remotes:

    git clone https://github.com/<your-username>/butler
    cd butler
    git remote add upstream https://github.com/keathley/butler

2) If your local copy gets behind the upstream repo you can update your fork:

    git checkout master
    git pull upstream master
    git push

3) Create a new topic branch off of master:

    git checkout -b <your-branch-name>
    
4) Commit your changes in logical chunks. Please include a short message on the first line and a more meaningful message on the following lines. Feel free to squash or rearrange commits with rebase if you need to.
5) Make sure all of the tests are passing at each commit.
    
    mix test
    
6) Push your branch up to your fork

    git push origin <your-branch-name>
    
7) Open a pull request. Please include a clear title and a description.
8) If your pull request falls behind master you can rebase your branch against master:

    git checkout master
    git pull upstream master
    git checkout <your-branch-name>
    git rebase master
    
Thanks! Looking forward to your contributions.
