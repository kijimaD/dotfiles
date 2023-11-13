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
		cpSensitiveFile,
		expandInotify,
		getDotfiles,
		initCrontab,
		initDocker,
	}
	for _, task := range tasks {
		err := task(ctx)
		if err != nil {
			return err
		}
	}
	return nil
}
