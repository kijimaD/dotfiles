package cmd

import (
	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var RegisterTasks []silver.Task

var cmds = []*cli.Command{
	// 依存なし
	CmdCpSensitiveFile,
	CmdExpandInotify,
	CmdInitCrontab,
	CmdInstallApt,
	CmdInitGuix,
	CmdRunGuixInstall,

	// SSH設定が必要
	CmdGetDotfiles,

	// Dockerが必要
	CmdInitDocker,

	// 依存あり
	CmdRunStow,
	CmdRunGclone,
	CmdInstGo,
	CmdInstGoPackages,
}

func NewApp() *cli.App {
	app := &cli.App{}
	app.Name = "build"
	app.Usage = "build subcommand"
	app.Description = "build my system"
	app.Version = "v0.0.0"
	app.EnableBashCompletion = true
	app.DefaultCommand = CmdAll.Name
	all := append(cmds, CmdAll)
	app.Commands = all

	return app
}

func RunApp(app *cli.App, args ...string) error {
	err := app.Run(args)
	if err != nil {
		return err
	}

	return err
}
