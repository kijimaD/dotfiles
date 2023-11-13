package cmd

import (
	"fmt"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdGetDotfiles = &cli.Command{
	Name:        "GetDotfiles",
	Usage:       "dotfilesリポジトリをcloneする",
	Description: "dotfilesリポジトリをcloneする",
	Action:      getDotfiles,
	Flags:       []cli.Flag{},
}

func getDotfiles(ctx *cli.Context) error {
	t := silver.NewTask("clone dotfiles")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistFile("~/dotfiles") },
		DepCmd:    func() bool { return silver.IsExistCmd("ssh") },
		InstCmd: func() error {
			targetDir := silver.HomeDir() + "/dotfiles"
			cmd := fmt.Sprintf("git clone https://github.com/kijimaD/dotfiles.git %s", targetDir)
			return t.Exec(cmd)
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
