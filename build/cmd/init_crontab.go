package cmd

import (
	"fmt"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInitCrontab = &cli.Command{
	Name:        "InitCrontab",
	Usage:       "crontabをセットする",
	Description: "crontabをセットする",
	Action:      initCrontab,
	Flags:       []cli.Flag{},
}

func initCrontab(ctx *cli.Context) error {
	t := silver.NewTask("initialize crontab")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return !silver.OnContainer() },
		InstCmd: func() error {
			targetDir := silver.HomeDir() + "/dotfiles/crontab"
			cmd := fmt.Sprintf("crontab %s", targetDir)
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
