package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"

	silver "github.com/kijimad/silver/pkg"
)

func main() {
	tasks := []silver.Task{
		getDotfiles(),
		cpSensitiveFile(),
		expandInotify(),
		initCrontab(),
		initDocker(),
		initGo(),
		runStow(),
		runGclone(),
	}
	job := silver.NewJob(tasks)
	job.Run()
}

func example() silver.Task {
	t := silver.NewTask("name")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return false },
		DepCmd:    func() bool { return true },
		InstCmd:   func() error { return nil },
	})
	return t
}

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

// Goをインストールする
// TODO: インストールしたあとにパスを通すのはどうしよう。ほかのコマンドに波及するのだろうか?
func initGo() silver.Task {
	const GoVersion = "1.20.1"

	t := silver.NewTask("initialize Go")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: func() bool { return silver.IsExistCmd("go") },
		DepCmd:    func() bool { return silver.IsExistCmd("curl") },
		InstCmd: func() error {
			// 処理系 ================
			curlcmd := fmt.Sprintf("curl -OL https://go.dev/dl/go%s.linux-amd64.tar.gz", GoVersion)
			err := t.Exec(curlcmd)
			if err != nil {
				return err
			}
			tarcmd := fmt.Sprintf("sudo tar -C /usr/local -xzf go%s.linux-amd64.tar.gz", GoVersion)
			err = t.Exec(tarcmd)
			if err != nil {
				return err
			}
			// packages ================
			repos := []string{
				"github.com/kijimaD/gclone@main",
				"github.com/kijimaD/garbanzo@main",
				"golang.org/x/tools/gopls@latest",
				"github.com/go-delve/delve/cmd/dlv@latest",
				"github.com/nsf/gocode@latest",
				"golang.org/x/tools/cmd/godoc@latest",
				"golang.org/x/tools/cmd/goimports@latest",
				"mvdan.cc/gofumpt@latest",
			}
			for _, repo := range repos {
				cmd := fmt.Sprintf("go install %s", repo)
				err = t.Exec(cmd)
				if err != nil {
					log.Fatal(err)
				}
			}
			return nil
		},
	})
	return t
}

func runStow() silver.Task {
	t := silver.NewTask("run stow")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("stow") },
		InstCmd: func() error {
			dotfiles := fmt.Sprintf("%s/dotfiles", silver.HomeDir())
			cmd := exec.Command("bash", "-c", "stow .")
			cmd.Dir = dotfiles
			_, err := cmd.CombinedOutput()
			if err != nil {
				return err
			}

			return nil
		},
	})
	return t
}

func runGclone() silver.Task {
	t := silver.NewTask("run gclone")
	t.SetFuncs(silver.ExecFuncParam{
		TargetCmd: nil,
		DepCmd:    func() bool { return silver.IsExistCmd("gclone") && silver.IsExistFile("~/dotfiles") },
		InstCmd: func() error {
			cmd := fmt.Sprintf("gclone -f %s/dotfiles/gclone.yml", silver.HomeDir())
			err := t.Exec(cmd)
			if err != nil {
				return err
			}
			return nil
		},
	})
	return t
}
