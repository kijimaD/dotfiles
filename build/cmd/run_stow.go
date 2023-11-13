package cmd

import (
	"fmt"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdRunStow = &cli.Command{
	Name:        "RunStow",
	Usage:       "",
	Description: "stowを実行して設定ファイルをホームディレクトリに展開する",
	Action:      runStow,
	Flags:       []cli.Flag{},
}

func runStow(ctx *cli.Context) error {
	t := silver.NewTask("run stow")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("stow") },
		InstCmd: func() error {
			cmd := fmt.Sprintf("cd ~/dotfiles && stow .")
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
