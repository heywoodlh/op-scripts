### Script descriptions:

`slab.sh` provides sudo-like-a-boss functionality ([original-repo](https://github.com/ravenac95/sudolikeaboss) -- watch the GIF in the README)


### MacOS Installation:

Install the dependencies:

bw: `brew install 1password-cli choose jq`


Download op-scripts:

`sudo chown -R "$USER":"$USER" /opt`

`git clone https://github.com/heywoodlh/op-scripts /opt/op-scripts`



### Linux Installation:

Install the dependencies (Debian/Ubuntu): 

`curl -O 'https://cache.agilebits.com/dist/1P/op/pkg/v0.5.3/op_linux_amd64_v0.5.3.zip'; sudo cp op /usr/bin/op; rm op op_linux_amd64_v0.5.1.zip op.sig`

`sudo apt-get install xclip rofi jq zenity`


Download op-scripts:

`sudo chown -R "$USER":"$USER" /opt`

`git clone https://github.com/heywoodlh/op-scripts /opt/op-scripts`



### Usage:

Initial login:

`op signin <subdomain> <email> <secret key>`

`slab.sh` reads `~/.op_session` for it's session ID. Therefore, login this way in the future:

`op signin --output=raw > ~/.op_session`

Edit the 'OP_SESSION_NAME' variable at the top of `/opt/op-scripts/slab.sh` to reflect the variable that `op` recommends you export when you login.

I.E. OP_SESSION_NAME would be 'OP_SESSION_my_team' if I have this output after I sign in:

```
export *OP_SESSION_my_team*="<session>"
# This command is meant to be used with your shell's eval function.
# Run 'eval $(op signin my_team)' to sign into your 1Password account.
# If you wish to use the session token itself, pass the --output=raw flag value. 
```



Once logged in, `slab.sh` should be suitable for use. Either create a keyboard shortcut the scripts in `/opt/op-scripts` or invoke the scripts from the CLI.

`slab.sh` will only return login items in the vault with a corresponding URI of `sudolikeaboss://`. So any entry you'd like to have returned by `slab` will need to have that URI. 

Also, `slab.sh` doesn't intelligently work with names so if an entry returns multiple values it will not work. I recommend naming each item in your vault that you'd like to have returned by `slab.sh` a really unique name (I.E. `Google Personal Account -- SLAB`) so that `slab.sh` doesn't return multiple values.

