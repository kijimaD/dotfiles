package cmd

import (
	"github.com/urfave/cli/v2"
)

var CmdAll = &cli.Command{
	Name:        "All",
	Usage:       "",
	Description: "すべてのタスクを実行する",
	Action:      all,
	Flags:       []cli.Flag{},
}

func all(ctx *cli.Context) error {
	tasks := []func(*cli.Context) error{
		CmdCpSensitiveFile.Action,
		CmdExpandInotify.Action,
		CmdGetDotfiles.Action,
		CmdInitCrontab.Action,
		CmdInitDocker.Action,
		CmdInstGo.Action,
		CmdInstGoPackages.Action,
		CmdRunStow.Action,
		CmdInstallApt.Action,
	}
	for _, task := range tasks {
		err := task(ctx)
		if err != nil {
			return err
		}
	}
	return nil
}
