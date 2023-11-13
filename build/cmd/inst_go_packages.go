package cmd

import (
	"fmt"
	"log"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInstGoPackages = &cli.Command{
	Name:        "InstGoPackages",
	Usage:       "Go packageをインストールする",
	Description: "Go packageをインストールする",
	Action:      instGoPackages,
	Flags:       []cli.Flag{},
}

func instGoPackages(ctx *cli.Context) error {
	t := silver.NewTask("install Go package")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("go") },
		InstCmd: func() error {
			repos := []string{
				"github.com/kijimaD/gclone@main",
				"github.com/kijimaD/garbanzo@main",
				"github.com/kijimaD/wei@main",
				"golang.org/x/tools/gopls@latest",
				"github.com/go-delve/delve/cmd/dlv@latest",
				"github.com/nsf/gocode@latest",
				"golang.org/x/tools/cmd/godoc@latest",
				"golang.org/x/tools/cmd/goimports@latest",
				"mvdan.cc/gofumpt@latest",
				"github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.2",
			}
			for _, repo := range repos {
				cmd := fmt.Sprintf("go install %s", repo)
				err := t.Exec(cmd)
				if err != nil {
					log.Fatal(err)
				}
			}
			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
