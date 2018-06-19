# Kubevaultenv

Based on the idea of vaultenv: https://github.com/channable/vaultenv

This project fetches secrets from vault using kubernetes auth https://www.vaultproject.io/docs/auth/kubernetes.html

Steps:
* authenticate to vault using kubernetes serviceaccount token
* read key value pairs from vault
* set them as environemtn variables
* calls exec with the provided 

## To add to your docker container:

```
ADD https://github.com/etheld/kubevaultenv/releases/download/0.1.9/kubevaultenv-amd64 /usr/local/bin/vaultenv
chmod +x /usr/local/bin/vaultenv
```

Run your application with it:
```exec /vaultenv -r <role> -k <path to secret> -s <vault_url> process parameters```

