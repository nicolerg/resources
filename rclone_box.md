# How to use rclone with Stanford Box

Find the rclone documentation for Box [here](https://rclone.org/box/). 

## Table of Contents 
- [Create a Box remote](#create-a-box-remote)
- [Reauthorize existing Box remote](#reauthorize-existing-box-remote)
- [Mount Box](#mount-box)
- [Copy files *to* Box](#copy-files-to-box)
  - [Copy a few files < 15GB to Box](#copy-a-few-files--15gb-to-box)
  - [Copy a large folder to Box](#copy-a-large-folder-to-box)
- [Restore old files *from* Box](#restore-old-files-from-box)

# Create a Box remote

You can log into Stanford Box [here](https://stanford.app.box.com/). Through the web app, you can view your files, share them with collaborators, etc. 

If you want to copy files from SCG or another cluster to Box, you will need to create a remote. Follow these steps:

1. Download rclone to your personal computer. Both Windows and Mac users can download the rclone binary directly from the [rclone downloads page](https://rclone.org/downloads/). If you are a Mac user and use Homebrew, you can install rclone with `brew install rclone`.
2. If you are not on SCG (i.e. Durga, Sherlock, or a cloud provider), you will also need to download rclone to your account on the server. You should use the AMD 64 - 64 bit Linux version. The download can be retrieved with `wget` and extracted with `unzip`. You should place the rclone binary you extract from the folder into `$HOME/.local/bin`, where it will always be accessible to you (this folder is added to your $PATH by default).
3. On your personal computer, open a terminal and type `rclone authorize box`. A browser window will pop up in your default browser, where you will be asked to sign in to Box, and then grant rclone access to it. When finished, you will see that one of the last lines of output in the terminal will be an authorization token. Save this for later. 
4. Log onto the server from which you want to transfer files. Run `rclone config` and follow these prompts (every `>` is a user-entered answer). This example creates a remote named "box", but you can call it whatever you want. 

    ```
    No remotes found - make a new one
    n) New remote
    s) Set configuration password
    q) Quit config
    n/s/q> n
    name> box
    Type of storage to configure.
    Choose a number from below, or type in your own value
    [snip]
    XX / Box
       \ "box"
    [snip]
    Storage> **box**
    Box App Client Id - leave blank normally.
    client_id> 
    Box App Client Secret - leave blank normally.
    client_secret>
    Box App config.json location
    Leave blank normally.
    Enter a string value. Press Enter for the default ("").
    config_json>
    'enterprise' or 'user' depending on the type of token being requested.
    Enter a string value. Press Enter for the default ("user").
    box_sub_type>
    Remote config
    Use auto config?
     * Say Y if not sure
     * Say N if you are working on a remote or headless machine
    y) Yes
    n) No
    y/n> n
    For this to work, you will need rclone available on a machine that has a web browser available.
    Execute the following on your machine:
            rclone authorize "box"
    Then paste the result below:
    result>
    ```

5. At this point, copy and paste the full authorization token from your local computer at the `result>` prompt above, from `{` to `}`. An example is: 

    ```
    {"access_token":"UHvp5762VbklcmGiTzMgISbsiNd88Xb7","token_type":"bearer","refresh_token":"mznwinE40xI6cHVFEQWOB5wC4yiblSyMc7VFCXzdPA19zMPgG2ZR4y41itPhT1EZS","expiry":"2020-04-27T17:46:41.031981-07:00"}
    ```

You have now created a new remote!

# Reauthorize existing Box remote

According to the [box docs](https://developer.box.com/v2.0/docs/oauth-20#section-6-using-the-access-and-refresh-tokens):

> Each refresh_token is valid for one use in 60 days.

This means that if you

- Don’t use the box remote for 60 days
- Copy the config file with a box refresh token in and use it in two places
- Get an error on a token refresh

then rclone will return an error which includes the text `Invalid refresh token`. This means you have to refresh the token. Do the following:

1. On your personal computer, open a terminal and type `rclone authorize box`. A browser window will pop up in your default browser, where you will be asked to sign in to Box, and then grant rclone access to it. When finished, you will see that one of the last lines of output in the terminal will be an authorization token. Save this for later. 
2. On SCG or another remote machine, run `rclone config` and follow these prompts:

    ```
    Current remotes:

    Name                 Type
    ====                 ====
    box                  box

    e) Edit existing remote
    n) New remote
    d) Delete remote
    r) Rename remote
    c) Copy remote
    s) Set configuration password
    q) Quit config
    e/n/d/r/c/s/q> e
    Choose a number from below, or type in an existing value
     1 > box
    remote> 1
    --------------------
    [box]
    type = box
    token = {"access_token":"ZT2C7LYdkThi7Jr84lIq9pLS5nus6mCc","token_type":"bearer","refresh_token":"cAk2vr8xyI98i9hdyJJHGsgoDMvsaJgkjnsdfkI3WcWi8","expiry":"2019-02-27T16:17:10.600238047-08:00"}
    --------------------
    Edit remote
    ** See help for box backend at: https://rclone.org/box/ **

    Value "client_id" = ""
    Edit? (y/n)>
    y) Yes
    n) No
    y/n> n
    Value "client_secret" = ""
    Edit? (y/n)>
    y) Yes
    n) No
    y/n> n
    Edit advanced config? (y/n)
    y) Yes
    n) No
    y/n> n
    --------------------
    [Box]
    type = box
    token = {"access_token":"ZT2C7LYdkThi7Jr84lIq9pLS5nus6mCc","token_type":"bearer","refresh_token":"cAk2vr8xyI98i9hdyJJHGsgoDMvsaJgkjnsdfkI3WcWi8","expiry":"2019-02-27T16:17:10.600238047-08:00"}
    --------------------
    y) Yes this is OK
    e) Edit this remote
    d) Delete this remote
    y/e/d> y
    Remote config
    Already have a token - refresh?
    y) Yes
    n) No
    y/n> y
    Use auto config?
     * Say Y if not sure
     * Say N if you are working on a remote or headless machine
    y) Yes
    n) No
    y/n> n
    For this to work, you will need rclone available on a machine that has a web browser available.
    Execute the following on your machine:
            rclone authorize "box"
    Then paste the result below:
    result> 
    ```

3. At this point, copy and paste the full authorization token from your local computer at the `result>` prompt above.
4. You should now see this:

    ```
    Current remotes:

    Name                 Type
    ====                 ====
    box                  box

    e) Edit existing remote
    n) New remote
    d) Delete remote
    r) Rename remote
    c) Copy remote
    s) Set configuration password
    q) Quit config
    e/n/d/r/c/s/q> q
    ```

You have now refreshed authorization for this remote!

# Mount Box

You need to mount Box if you want to copy files to/from Box. Use the `rclone mount [remote:path/to/files] [/path/to/local/mount] &` command, where `[remote:path/to/files]` is a path through your remote on Box, and `[/path/to/local/mount]` is the local path to which you want to mount Box. You MUST include `&` to run rclone in the background. Otherwise, the command will just hang forever. For example:

```bash
rclone mount box:some_lab/some_user /labs/some_lab/some_user/BOX &
```

Once you're done working with Box, use `killall rclone` or otherwise kill the `rclone mount` process running in the background to disconnect from Box. 

# Copy files *to* Box

## Copy a few files < 15GB to Box

See the next section if you would like to copy a single large folder to Box. Alternatively, if you would like to have more control over how a large amount of data is tarred, generate gzipped tarballs yourself and copy them to Box. For example, if you have a few tarballs that are less than 15GB each, move them to a new otherwise empty folder called `transfer`. Then use `rclone copy [source] [destn]`, e.g. `rclone copy transfer Box:some_lab/some_user/PROJECT_BACKUP`

This will copy all files in `transfer` (but not the directory itself) to the `some_lab/some_user/PROJECT_BACKUP` path on Box. If the destination path does not yet exist on Box, running this command will make it and place files in `transfer` there.

## Copy a large folder to Box

Box has an individual file limit of 15GB. This means files larger than 15GB must be chunked into smaller files. Mike Gloudemans has written a script to facilitate this process if you would like to copy an entire folder to Box:

> WARNING: This script is not the most efficient so it actually takes up a lot of space in intermediate files while it's running. Please make sure you understand what it's doing before using it.

> ANOTHER WARNING: I highly highly recommend that before deleting the original file, you download and attempt to restore your original file / directory from Box. You can do this by comparing md5sums of the original and restored folders (included in the script itself). This might seems silly but it is very easy to accidentally miss uploading one chunk of the tar archive, which could potentially lose the entire contents. (I almost did this myself once with a 5 TB folder but got very lucky in that I hadn't deleted the original folder yet.)

> Hey everyone, I wanted to share this script that will automatically tar the contents of a folder into 10GB or less and upload them to the PHI folder on Box. (It then will redownload all these files into a new subdirectory and verify that the original directory can be recreated.)

```bash
# Backup to box
# Author: Mike Gloudemans
# Date: 3/18/2019

# Uploads tarred and zipped contents of the selected folder to Box PHI folder.
# Then re-downloads them, re-assembles the folder, and checks to make sure
# everything's the same.

# Just so you can be sure everything's the same, the re-assembled copy
# isn't deleted until you run this script again.

# Input argument: the absolute path of the folder that 
# you want to back up to Box. Relative paths may not work well

# NOTE: If you haven't run rclone for Box before, you'll
# need to configure rsync as explained in
# https://rclone.org/box/.
# When prompted for the remote name, enter 'box', or else
# this script won't work.

# Warning: This temporary folder is deleted every time you start a run!
# Don't put important files in it!
rm -r reconstruction
mkdir reconstruction

# Make backup, upload to Box
file=`echo $1 | sed 's/\//./g'`
file="backup$file"
echo $file
echo $1
tar -czvf reconstruction/$file.pre.tar.gz $1
cat reconstruction/$file.pre.tar.gz | split --bytes=10GB -  reconstruction/$file.tar.gz
rm reconstruction/$file.pre.tar.gz
rclone copy reconstruction box:some_lab/some_folder$1

# Download from Box
mkdir reconstruction/assembly
rclone copy box:some_lab/some_folder$1 reconstruction/assembly/
cat reconstruction/assembly/*.tar.gz* > reconstruction/assembly/$file.tar.gz
ionice -c 2 -n 7 -p $!
tar -xvzf reconstruction/assembly/$file.tar.gz -C reconstruction/assembly/

# Check md5sums
find reconstruction/assembly/$1 -type f -exec md5sum {} + | awk '{print $1}' | sort | md5sum > reconstruction/assembly/md5_box.md5
find $1 -type f -exec md5sum {} + | awk '{print $1}' | sort | md5sum > reconstruction/assembly/md5_local.md5

# md5sums should be the same
# Please verify this before deleting locally stored files
cat reconstruction/assembly/md5*
# or
diff reconstruction/assembly/md5_local.md5 reconstruction/assembly/md5_box.md5
```

# Restore old files *from* Box

First, you need to have rclone configured for use with Box (see [Create a Box remote](https://www.notion.so/How-to-use-Box-d765dbc663af457fa83c0b8108d2b06a#f5be0c58626d4bd38c68c9f969772dff)). 

You can download single files with the `rclone copy` command:
```bash
rclone copy Box:some_lab/some_user/PROJECT_BACKUP /labs/some_lab/some_user/RESTORE 
```

If you used the tarball chunking script above, you can restore the folder with the following commands:
```bash
# Download files      
rclone copy box:some_lab/some_user/PROJECT_BACKUP /labs/some_lab/some_user/RESTORE 

# Reassemble chunked tar files into one single archive
cat /labs/some_lab/some_user/RESTORE/tar* > /labs/some_lab/some_user/RESTORE/transfer.tar

# Extract tar archive
tar -xvf /labs/some_lab/some_user/RESTORE/transfer.tar

# Clean up tar files after unzipping
rm /labs/some_lab/some_user/RESTORE/*tar*      
```

Note that the `box` part of the `rclone copy` command needs to be whatever you named your remote in the configuration step (it doesn’t matter what it’s called). 

Also, not all folders on Box are tarred, so in some cases you might only have to run the first command.
