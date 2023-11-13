package main

import (
	"os"

	"github.com/dotfiles/cube/cmd"
	"github.com/kijimad/silver"
)

// env
// - LONG: 長い時間がかかるコマンドは環境変数LONGを必須にしておいて、LONGをつけない場合は実行をスキップする
func main() {
	app := cmd.NewApp()
	_ = cmd.RunApp(app, os.Args...)

	job := silver.NewJob(cmd.RegisterTasks)
	job.Run()
}
