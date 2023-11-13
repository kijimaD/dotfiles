package cmd

import (
	"fmt"
	"os/user"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInitDocker = &cli.Command{
	Name:        "InitDocker",
	Usage:       "dockerをsudoなしで使えるようにする",
	Description: "dockerをsudoなしで使えるようにする",
	Action:      initDocker,
	Flags:       []cli.Flag{},
}

func initDocker(ctx *cli.Context) error {
	t := silver.NewTask("initialize docker")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistCmd("docker") },
		DepCmd:    func() bool { return !silver.OnContainer() },
		InstCmd: func() error {
			currentUser, err := user.Current()
			if err != nil {
				return err
			}
			username := currentUser.Username
			cmd := fmt.Sprint("sudo gpasswd -a %s docker", username)
			err = t.Exec(cmd)
			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
