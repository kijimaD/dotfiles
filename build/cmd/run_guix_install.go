package cmd

import (
	"os"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdRunGuixInstall = &cli.Command{
	Name:        "RunGuixInstall",
	Usage:       "",
	Description: "desktop.scmに記載されているパッケージをインストールする",
	Action:      runGuixInstall,
	Flags:       []cli.Flag{},
}

func runGuixInstall(ctx *cli.Context) error {
	t := silver.NewTask("run guix install")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd: func() bool {
			_, long := os.LookupEnv("LONG")
			return silver.IsExistCmd("guix") &&
				long
		},
		InstCmd: func() error {
			cmd := "guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm"
			err := t.Exec(cmd)
			if err != nil {
				return err
			}
			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
