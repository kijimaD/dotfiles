package cmd

import (
	"fmt"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInstGo = &cli.Command{
	Name:        "InstGo",
	Usage:       "",
	Description: "Goをビルド+インストールする",
	Action:      instGo,
	Flags:       []cli.Flag{},
}

func instGo(ctx *cli.Context) error {
	const GoVersion = "1.20.2"
	t := silver.NewTask("install Go")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistCmd("go") },
		DepCmd:    func() bool { return silver.IsExistCmd("guix") },
		InstCmd: func() error {
			err := t.Exec(fmt.Sprintf("guix build go@%s", GoVersion))
			if err != nil {
				return err
			}
			err = t.Exec(fmt.Sprintf("guix package -i go@%s", GoVersion))
			if err != nil {
				return err
			}
			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
