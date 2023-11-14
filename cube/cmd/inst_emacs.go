package cmd

import (
	"fmt"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInstEmacs = &cli.Command{
	Name:        "InstEmacs",
	Usage:       "Emacsをインストールする",
	Description: "Emacsをインストールする",
	Action:      instEmacs,
	Flags:       []cli.Flag{},
}

func instEmacs(ctx *cli.Context) error {
	const emacsVersion = "29.1"
	t := silver.NewTask("install Emacs")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistCmd("emacs") },
		DepCmd:    func() bool { return silver.IsExistCmd("guix") },
		InstCmd: func() error {
			err := t.Exec(fmt.Sprintf("guix build emacs@%s && guix package -i emacs@%s", emacsVersion, emacsVersion))
			if err != nil {
				return err
			}
			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
