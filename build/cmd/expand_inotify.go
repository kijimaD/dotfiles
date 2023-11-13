package cmd

import (
	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdExpandInotify = &cli.Command{
	Name:        "ExpandInotify",
	Usage:       "inotifyを増やす",
	Description: "inotifyを増やす",
	Action:      expandInotify,
	Flags:       []cli.Flag{},
}

// ホストマシン上だけで実行する。コンテナからは/procに書き込みできないためエラーになる
func expandInotify(ctx *cli.Context) error {
	t := silver.NewTask("expand inotify")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return !silver.OnContainer() },
		InstCmd:   func() error { return t.Exec("echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf") },
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
