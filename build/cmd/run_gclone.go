package cmd

import (
	"fmt"
	"os"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdRunGclone = &cli.Command{
	Name:        "RunGclone",
	Usage:       "gcloneを実行してリポジトリをクローンする",
	Description: "gcloneを実行してリポジトリをクローンする",
	Action:      runGclone,
	Flags:       []cli.Flag{},
}

func runGclone(ctx *cli.Context) error {
	t := silver.NewTask("run gclone")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd: func() bool {
			_, long := os.LookupEnv("LONG")
			return silver.IsExistCmd("gclone") &&
				silver.IsExistFile("~/dotfiles") &&
				long
		},
		InstCmd: func() error {
			cmd := fmt.Sprintf("gclone -f ~/dotfiles/gclone.yml")
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
