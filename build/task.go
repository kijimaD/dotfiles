package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/user"
	"strings"

	"github.com/kijimad/silver"
)

// 自分のdotfilesをクローンする
func getDotfiles() silver.Task {
	t := silver.NewTask("clone dotfiles")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistFile("~/dotfiles") },
		DepCmd:    func() bool { return silver.IsExistCmd("ssh") },
		InstCmd: func() error {
			targetDir := silver.HomeDir() + "/dotfiles"
			cmd := fmt.Sprintf("git clone https://github.com/kijimaD/dotfiles.git %s", targetDir)
			return t.Exec(cmd)
		},
	})
	return t
}

// バージョン管理に入れないがテンプレートは用意したいファイルをコピーする
func cpSensitiveFile() silver.Task {
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
	return t
}

// inotifyを増やす
// ホストマシンだけで実行する。コンテナからは/procに書き込みできないためエラーになる
func expandInotify() silver.Task {
	t := silver.NewTask("expand inotify")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return !silver.OnContainer() },
		InstCmd:   func() error { return t.Exec("echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf") },
	})
	return t
}

// crontabを実行する
func initCrontab() silver.Task {
	t := silver.NewTask("initialize crontab")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return !silver.OnContainer() },
		InstCmd: func() error {
			targetDir := silver.HomeDir() + "/dotfiles/crontab"
			cmd := fmt.Sprintf("crontab %s", targetDir)
			err := t.Exec(cmd)
			if err != nil {
				return err
			}
			return nil
		},
	})
	return t
}

// グループに追加してsudoなしで使えるようにする
func initDocker() silver.Task {
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
	return t
}

// Goをビルド+インストールする
// バージョン指定するためにビルドしてる。guixの設定ファイルで書けそう...
func instGo() silver.Task {
	const GoVersion = "1.20.2"
	t := silver.NewTask("install Go")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistCmd("go") },
		DepCmd:    func() bool { return silver.IsExistCmd("guix") },
		InstCmd: func() error {
			err := t.Exec(fmt.Sprintf("guix build go@%s", GoVersion))
			if err != nil {
				return err
			}
			err = t.Exec(fmt.Sprintf("guix package -i go@%s", GoVersion))
			if err != nil {
				return err
			}
			return nil
		},
	})
	return t
}

// Go packageをインストールする
func instGoPackages() silver.Task {
	t := silver.NewTask("install Go package")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("go") },
		InstCmd: func() error {
			repos := []string{
				"github.com/kijimaD/gclone@main",
				"github.com/kijimaD/garbanzo@main",
				"github.com/kijimaD/wei@main",
				"golang.org/x/tools/gopls@latest",
				"github.com/go-delve/delve/cmd/dlv@latest",
				"github.com/nsf/gocode@latest",
				"golang.org/x/tools/cmd/godoc@latest",
				"golang.org/x/tools/cmd/goimports@latest",
				"mvdan.cc/gofumpt@latest",
			}
			for _, repo := range repos {
				cmd := fmt.Sprintf("go install %s", repo)
				err := t.Exec(cmd)
				if err != nil {
					log.Fatal(err)
				}
			}
			return nil
		},
	})
	return t
}

// stowを実行して設定ファイルをホームディレクトリに展開する
func runStow() silver.Task {
	t := silver.NewTask("run stow")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("stow") },
		InstCmd: func() error {
			cmd := fmt.Sprintf("cd ~/dotfiles && stow .")
			err := t.Exec(cmd)
			if err != nil {
				return err
			}

			return nil
		},
	})
	return t
}

// aptで管理しているパッケージをインストールする
func installApt() silver.Task {
	t := silver.NewTask("install apt")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("apt") },
		InstCmd: func() error {
			updatecmd := "sudo apt update"
			err := t.Exec(updatecmd)
			if err != nil {
				return err
			}
			packages := []string{
				"emacs-mozc",
				"cmigemo",
				"fcitx-mozc",
				"peco",
				"silversearcher-ag",
				"compton",
				"qemu-kvm",
				"libsqlite3-dev", // roam用
			}
			installcmd := fmt.Sprintf("sudo apt install -y %s", strings.Join(packages, " "))
			err = t.Exec(installcmd)
			if err != nil {
				return err
			}

			return nil
		},
	})
	return t
}

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
