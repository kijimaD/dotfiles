package main

import "github.com/kijimad/silver"

// env
// - LONG: 長い時間がかかるコマンドは環境変数LONGを必須にしておいて、LONGをつけない場合は実行をスキップする

// 途中で終わったら即終了するか、継続するか制御したい
func main() {
	tasks := []silver.Task{
		getDotfiles(),
		cpSensitiveFile(),
		expandInotify(),
		initCrontab(),
		initDocker(),
		initGo(),
		runStow(),
		installApt(),
		runGclone(),
		initGuix(),
		runGuixInstall(),
	}
	job := silver.NewJob(tasks)
	job.Run()
}
