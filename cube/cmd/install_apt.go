package cmd

import (
	"fmt"
	"strings"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInstallApt = &cli.Command{
	Name:        "InstallApt",
	Usage:       "aptのパッケージをインストールする",
	Description: "aptのパッケージをインストールする",
	Action:      installApt,
	Flags:       []cli.Flag{},
}

func installApt(ctx *cli.Context) error {
	t := silver.NewTask("install apt")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("apt") },
		InstCmd: func() error {
			updatecmd := "sudo apt update -y"
			err := t.Exec(updatecmd)
			if err != nil {
				return err
			}
			packages := []string{
				"cmigemo",
				"compton",
				"emacs-mozc",
				"fcitx-mozc",
				"git",
				"libsqlite3-dev", // roam用
				"peco",
				"qemu-kvm",
				"silversearcher-ag",
				"vlc", // eradio
			}
			installcmd := fmt.Sprintf("sudo apt install -y %s", strings.Join(packages, " "))
			err = t.Exec(installcmd)
			if err != nil {
				return err
			}

			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
