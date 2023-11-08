package main

import (
	"os"

	"github.com/dotfiles/silver/cmd"
	"github.com/kijimad/silver"
)

// env
// - LONG: 長い時間がかかるコマンドは環境変数LONGを必須にしておいて、LONGをつけない場合は実行をスキップする

// 途中で終わったら即終了するか、継続するか制御したい
func main() {
	// tasks := []silver.Task{
	// 	getDotfiles(),
	// 	cpSensitiveFile(),
	// 	expandInotify(),
	// 	initCrontab(),
	// 	initDocker(),
	// 	initGo(),
	// 	runStow(),
	// 	installApt(),
	// 	runGclone(),
	// 	initGuix(),
	// 	runGuixInstall(),
	// }

	app := cmd.NewApp()
	_ = cmd.RunApp(app, os.Args...)

	job := silver.NewJob(cmd.RegisterTasks)
	job.Run()
}
