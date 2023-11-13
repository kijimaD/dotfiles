package main

import (
	"fmt"
	"os"

	"github.com/kijimad/silver"
)

// gcloneを実行してリポジトリをクローンする
func runGclone() silver.Task {
	t := silver.NewTask("run gclone")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd: func() bool {
			_, long := os.LookupEnv("LONG")
			return silver.IsExistCmd("gclone") &&
				silver.IsExistFile("~/dotfiles") &&
				long
		},
		InstCmd: func() error {
			cmd := fmt.Sprintf("gclone -f ~/dotfiles/gclone.yml")
			err := t.Exec(cmd)
			if err != nil {
				return err
			}
			return nil
		},
	})
	return t
}

// Guixをインストールする
func initGuix() silver.Task {
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
	return t
}

// desktop.scmに記載されているパッケージをインストールする
func runGuixInstall() silver.Task {
	t := silver.NewTask("run guix install")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd: func() bool {
			_, long := os.LookupEnv("LONG")
			return silver.IsExistCmd("guix") &&
				long
		},
		InstCmd: func() error {
			cmd := "guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm"
			err := t.Exec(cmd)
			if err != nil {
				return err
			}
			return nil
		},
	})
	return t
}
