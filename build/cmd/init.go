package cmd

import (
	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var RegisterTasks []silver.Task

func NewApp() *cli.App {
	app := &cli.App{}
	app.Name = "build"
	app.Usage = "build subcommand"
	app.Description = "build my system"
	app.Version = "v0.0.0"
	app.EnableBashCompletion = true
	app.DefaultCommand = CmdAll.Name
	app.Commands = []*cli.Command{
		CmdAll,
		CmdCpSensitiveFile,
		CmdExpandInotify,
		CmdGetDotfiles,
		CmdInitCrontab,
		CmdInitDocker,
	}

	return app
}

func RunApp(app *cli.App, args ...string) error {
	err := app.Run(args)
	if err != nil {
		return err
	}

	return err
}
