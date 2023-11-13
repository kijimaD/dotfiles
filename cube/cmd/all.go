package cmd

import (
	"github.com/urfave/cli/v2"
)

var CmdAll = &cli.Command{
	Name:        "All",
	Usage:       "すべてのタスクを実行する",
	Description: "すべてのタスクを実行する",
	Action:      all,
	Flags:       []cli.Flag{},
}

func all(ctx *cli.Context) error {
	var tasks []func(*cli.Context) error
	for _, c := range cmds {
		tasks = append(tasks, c.Action)
	}
	for _, task := range tasks {
		err := task(ctx)
		if err != nil {
			return err
		}
	}
	return nil
}
