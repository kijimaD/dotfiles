package cmd

import (
	"errors"
	"os"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdCpSensitiveFile = &cli.Command{
	Name:        "CpSensitiveFile",
	Usage:       "機微なファイルをコピーする",
	Description: "機微なファイルをコピーする",
	Action:      cpSensitiveFile,
	Flags:       []cli.Flag{},
}

func cpSensitiveFile(ctx *cli.Context) error {
	t := silver.NewTask("copy sensitive file")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistFile("~/.ssh/config") },
		DepCmd:    nil,
		InstCmd: func() error {
			// .sshディレクトリがない場合は作成する
			sshdir := silver.HomeDir() + "/.ssh/"
			if _, err := os.Stat(sshdir); errors.Is(err, os.ErrNotExist) {
				err := os.Mkdir(sshdir, os.ModePerm)
				if err != nil {
					return err
				}
			}
			_, err := silver.Copy("~/dotfiles/.ssh/config", "~/.ssh/config")
			if err != nil {
				return err
			}

			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
