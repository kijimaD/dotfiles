package cmd

import (
	"github.com/kijimad/silver"
	"github.com/urfave/cli/v2"
)

var CmdInitGuix = &cli.Command{
	Name:        "InitGuix",
	Usage:       "Guixをインストールする",
	Description: "Guixをインストールする",
	Action:      initGuix,
	Flags:       []cli.Flag{},
}

func initGuix(ctx *cli.Context) error {
	t := silver.NewTask("initialize guix")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistCmd("guix") },
		DepCmd:    func() bool { return !silver.OnContainer() },
		InstCmd: func() error {
			cmd := `cd /tmp && \
	wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
	chmod +x guix-install.sh && \
	yes | sudo ./guix-install.sh && \
	. ~/.bashrc && \
	sudo systemctl daemon-reload && \
	sudo systemctl restart guix-daemon && \
	guix pull && \
	hash guix
`
			err := t.Exec(cmd)
			if err != nil {
				return nil
			}
			return nil
		},
	})
	RegisterTasks = append(RegisterTasks, t)
	return nil
}
