package cmd

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdPreCheck = &cli.Command{
	Name:        "PreCheck",
	Usage:       "管理外の依存関係をチェックする",
	Description: "管理外の依存関係をチェックする",
	Action:      preCheck,
	Flags:       []cli.Flag{},
}

func preCheck(ctx *cli.Context) error {
	const successMsg = "You've successfully authenticated, but GitHub does not provide shell access."
	const ok = "✅"
	const ng = "-"
	t := silver.NewTask("pre check")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return false },
		DepCmd:    func() bool { return true },
		InstCmd: func() error {
			{
				out, _ := exec.Command("bash", "-c", fmt.Sprintf("ssh -T -o StrictHostKeyChecking=no git@github.com")).CombinedOutput()
				const entry = "GitHub SSH setting"
				if strings.Contains(string(out), successMsg) {
					fmt.Printf("%s %s\n", ok, entry)
				} else {
					fmt.Printf("%s %s\n", ng, entry)
				}
			}
			{
				isInstalledDocker := silver.IsExistCmd("docker")
				const entry = "Usable Docker"
				if isInstalledDocker {
					fmt.Printf("%s %s\n", ok, entry)
				} else {
					fmt.Printf("%s %s\n", ng, entry)
				}
			}

			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
