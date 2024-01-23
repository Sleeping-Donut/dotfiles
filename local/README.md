# User Local files

Put files into `~/.local`

## TODO

### install chatgpt shell

make a setup, install or src dir
put this in bash file
add condition if linux do the swap (macOS likes open not xdg_open (maybe alias xdg_open to open on macOS?))

```sh
curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/chatgpt.sh | sed -e 's/open "\${image_url}"/xdg-open "\${image_url}"/g' > ./chatgpt
chmod +x ./chatgpt
```
