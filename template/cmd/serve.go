package cmd

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/catalystsquad/app-utils-go/logging"
	"github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

// serveCmd represents the serve command
var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		serveExampleHTTPServer()
	},
}

type serveConfig struct {
	port int
}

var serveCfg = &serveConfig{}

func init() {
	rootCmd.AddCommand(serveCmd)
	cobra.OnInitialize(initServeConfig)

	serveCmd.Flags().IntVarP(&serveCfg.port, "port", "p", 8080, "port for example http server")
}

func initServeConfig() {
	viper.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
	viper.AutomaticEnv() // read in environment variables that match
	bindFlags(serveCmd)
}

func serveExampleHTTPServer() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello!")
	})
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "OK")
	})

	address := fmt.Sprintf(":%d", serveCfg.port)
	logging.Log.WithFields(logrus.Fields{"address": address, "path": "/"}).Info("starting example server")
	err := http.ListenAndServe(address, nil)
	if err != nil {
		logging.Log.WithError(err).Error("error running example server")
	}
}
