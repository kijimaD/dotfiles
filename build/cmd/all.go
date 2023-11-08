package cmd

import (
	"github.com/urfave/cli/v2"
)

var CmdAll = &cli.Command{
	Name:        "All",
	Usage:       "",
	Description: "すべて実行する",
	Action:      all,
	Flags:       []cli.Flag{},
}

func all(ctx *cli.Context) error {
	err := getDotfiles(ctx)
	if err != nil {
		return err
	}
	err = cpSensitiveFile(ctx)
	if err != nil {
		return err
	}
	return nil
}
