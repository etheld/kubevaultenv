package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"syscall"

	"github.com/hashicorp/vault/api"
)

type KubeVault struct {
	Address string
	Key     string
	Role string
	Client  *api.Client
}

func NewKubeVault(address string, key string, role string) *KubeVault {
	client, err := api.NewClient(&api.Config{
		Address: address,
	})
	if err != nil {
		fmt.Printf("Failed to create Vault client: %v", err)
		panic(err)
	}

	return &KubeVault{Address: address, Key: key, Client: client, Role: role}
}

func (k *KubeVault) login() {
	jwt, err := ioutil.ReadFile("token")

	if err != nil {
		fmt.Printf("token not found")
	}

	authParameters := map[string]interface{}{
		"jwt":  string(jwt[:]),
		"role": k.Role,
	}

	secret, err := k.Client.Logical().Write("/auth/kubernetes/login", authParameters)
	log.Println("client authenticated")
	k.Client.SetToken(secret.Auth.ClientToken)

}

func (k *KubeVault) readSecret() *api.Secret {
	sec, err := k.Client.Logical().Read(k.Key)
	if err != nil {
		fmt.Printf("No data for key %s\n", k.Key)
	}
	return sec
}

func main() {

	key := flag.String("k", "", "key of secret to be retrieved")
	address := flag.String("s", "", "server url for vault server")
	role := flag.String("r", "", "role for auth")
	flag.Parse()

	args := flag.Args()
	client := NewKubeVault(*address, *key, *role)
	client.login()
	secret := client.readSecret()

	for k, v := range secret.Data {
		log.Printf("Setting env variable %s\n", k)
		os.Setenv(k, fmt.Sprintf("%v", v))
	}

	if err := syscall.Exec(args[0], args[0:], os.Environ()); err != nil {
		log.Fatalf("error: exec failed: %v", err)
	}
}
