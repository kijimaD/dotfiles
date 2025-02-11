package cmd

import (
	"fmt"
	"os"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInitEmacs = &cli.Command{
	Name:        "InitEmacs",
	Usage:       "Emacsを設定する",
	Description: "Emacsを設定する",
	Action:      initEmacs,
	Flags:       []cli.Flag{},
}

func initEmacs(ctx *cli.Context) error {
	t := silver.NewTask("initialize Emacs")
	emacsDir := silver.HomeDir() + "/.emacs.d"
	caskDir := silver.HomeDir() + "/.cask"
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return false },
		DepCmd: func() bool {
			return silver.IsExistCmd("emacs") &&
				silver.IsExistCmd("git") &&
				silver.IsExistCmd("make")
		},
		InstCmd: func() error {
			// Git管理されている.emacs.dがなければ、削除してcloneする
			if f, err := os.Stat(fmt.Sprintf("%s/.git", emacsDir)); os.IsNotExist(err) || !f.IsDir() {
				// 削除
				os.RemoveAll(emacsDir)
				// clone
				err := t.Exec(fmt.Sprintf("git clone git@github.com:kijimaD/.emacs.d.git %s", emacsDir))
				if err != nil {
					return err
				}
			}

			// Git管理されている.caskがなければ、削除してcloneする
			if f, err := os.Stat(fmt.Sprintf("%s/.git", caskDir)); os.IsNotExist(err) || !f.IsDir() {
				// 削除
				os.RemoveAll(caskDir)
				// clone
				err := t.Exec(fmt.Sprintf("git clone https://github.com/cask/cask.git %s", caskDir))
				if err != nil {
					return err
				}
			}
			// vtermのyes/noで詰まるのでyesコマンドが必要
			err := t.Exec(fmt.Sprintf("cd %s && yes | %s/bin/cask", emacsDir, caskDir))
			if err != nil {
				return err
			}
			err = t.Exec(fmt.Sprintf("cd %s && make gen-el", emacsDir))
			if err != nil {
				return err
			}

			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
