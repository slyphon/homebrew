require "language/go"

class Influxdb < Formula
  desc "Time series, events, and metrics database"
  homepage "https://influxdata.com/time-series-platform/influxdb/"
  url "https://github.com/influxdata/influxdb/archive/v0.11.0.tar.gz"
  sha256 "04b4a1c9b2a84c44c0820eacf28a8ef7b301b27e4ed224d23c9fc4d63c2e644e"

  head "https://github.com/influxdata/influxdb.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d31080b1c23ad1714d3747bfa5fd40d271dd2eb9a39c0ada0edb4dcfa05fdbaa" => :el_capitan
    sha256 "97da776ca586004ff3940473a2d8fec34261b40e10a346405123faf6acf656fc" => :yosemite
    sha256 "4993701bd639a55cab9b26cd1c33f426e27bd501a9e247c92a5f1873d18d9cda" => :mavericks
  end

  depends_on "go" => :build

  go_resource "collectd.org" do
    url "https://github.com/collectd/go-collectd.git",
    :revision => "9fc824c70f713ea0f058a07b49a4c563ef2a3b98"
  end

  go_resource "github.com/BurntSushi/toml" do
    url "https://github.com/BurntSushi/toml.git",
    :revision => "a4eecd407cf4129fc902ece859a0114e4cf1a7f4"
  end

  go_resource "github.com/armon/go-metrics" do
    url "https://github.com/armon/go-metrics.git",
    :revision => "345426c77237ece5dab0e1605c3e4b35c3f54757"
  end

  go_resource "github.com/bmizerany/pat" do
    url "https://github.com/bmizerany/pat.git",
    :revision => "b8a35001b773c267eb260a691f4e5499a3531600"
  end

  go_resource "github.com/boltdb/bolt" do
    url "https://github.com/boltdb/bolt.git",
    :revision => "2f846c3551b76d7710f159be840d66c3d064abbe"
  end

  go_resource "github.com/davecgh/go-spew" do
    url "https://github.com/davecgh/go-spew.git",
    :revision => "fc32781af5e85e548d3f1abaf0fa3dbe8a72495c"
  end

  go_resource "github.com/dgryski/go-bits" do
    url "https://github.com/dgryski/go-bits.git",
    :revision => "86c69b3c986f9d40065df5bd8f765796549eef2e"
  end

  go_resource "github.com/dgryski/go-bitstream" do
    url "https://github.com/dgryski/go-bitstream.git",
    :revision => "27cd5973303fde7d914860be1ea4b927a6be0c92"
  end

  go_resource "github.com/gogo/protobuf" do
    url "https://github.com/gogo/protobuf.git",
    :revision => "82d16f734d6d871204a3feb1a73cb220cc92574c"
  end

  go_resource "github.com/golang/snappy" do
    url "https://github.com/golang/snappy.git",
    :revision => "5979233c5d6225d4a8e438cdd0b411888449ddab"
  end

  go_resource "github.com/hashicorp/go-msgpack" do
    url "https://github.com/hashicorp/go-msgpack.git",
    :revision => "fa3f63826f7c23912c15263591e65d54d080b458"
  end

  go_resource "github.com/hashicorp/raft" do
    url "https://github.com/hashicorp/raft.git",
    :revision => "8fd9a2fdfd154f4b393aa24cff91e3c317efe839"
  end

  go_resource "github.com/hashicorp/raft-boltdb" do
    url "https://github.com/hashicorp/raft-boltdb.git",
    :revision => "d1e82c1ec3f15ee991f7cc7ffd5b67ff6f5bbaee"
  end

  go_resource "github.com/influxdata/usage-client" do
    url "https://github.com/influxdata/usage-client.git",
    :revision => "475977e68d79883d9c8d67131c84e4241523f452"
  end

  go_resource "github.com/jwilder/encoding" do
    url "https://github.com/jwilder/encoding.git",
    :revision => "07d88d4f35eec497617bee0c7bfe651a796dae13"
  end

  go_resource "github.com/kimor79/gollectd" do
    url "https://github.com/kimor79/gollectd.git",
    :revision => "61d0deeb4ffcc167b2a1baa8efd72365692811bc"
  end

  go_resource "github.com/paulbellamy/ratecounter" do
    url "https://github.com/paulbellamy/ratecounter.git",
    :revision => "5a11f585a31379765c190c033b6ad39956584447"
  end

  go_resource "github.com/peterh/liner" do
    url "https://github.com/peterh/liner.git",
    :revision => "ad1edfd30321d8f006ccf05f1e0524adeb943060"
  end

  go_resource "github.com/rakyll/statik" do
    url "https://github.com/rakyll/statik.git",
    :revision => "274df120e9065bdd08eb1120e0375e3dc1ae8465"
  end

  go_resource "golang.org/x/crypto" do
    url "https://go.googlesource.com/crypto.git",
    :revision => "1f22c0103821b9390939b6776727195525381532"
  end

  go_resource "gopkg.in/fatih/pool.v2" do
    url "https://gopkg.in/fatih/pool.v2.git",
    :revision => "cba550ebf9bce999a02e963296d4bc7a486cb715"
  end

  def install
    ENV["GOPATH"] = buildpath
    influxdb_path = buildpath/"src/github.com/influxdata/influxdb"
    influxdb_path.install Dir["*"]

    Language::Go.stage_deps resources, buildpath/"src"

    cd influxdb_path do
      if build.head?
        system "go", "install", "-ldflags", "-X main.version=0.12.0-HEAD -X main.branch=master -X main.commit=#{`git rev-parse HEAD`.strip}", "./..."
      else
        system "go", "install", "-ldflags", "-X main.version=0.11.0 -X main.branch=0.11 -X main.commit=1572060c6890f5c6f6e540155d99238aca8617e3", "./..."
      end
    end

    inreplace influxdb_path/"etc/config.sample.toml" do |s|
      s.gsub! "/var/lib/influxdb/data", "#{var}/influxdb/data"
      s.gsub! "/var/lib/influxdb/meta", "#{var}/influxdb/meta"
      s.gsub! "/var/lib/influxdb/wal", "#{var}/influxdb/wal"
    end
    unless build.head?
      inreplace influxdb_path/"etc/config.sample.toml", "/var/lib/influxdb/hh", "#{var}/influxdb/hh"
    end

    bin.install "bin/influxd"
    bin.install "bin/influx"
    bin.install "bin/influx_tsm"
    bin.install "bin/influx_stress"
    etc.install influxdb_path/"etc/config.sample.toml" => "influxdb.conf"

    (var/"influxdb/data").mkpath
    (var/"influxdb/meta").mkpath
    (var/"influxdb/wal").mkpath
    unless build.head?
      (var/"influxdb/hh").mkpath
    end
  end

  plist_options :manual => "influxd -config #{HOMEBREW_PREFIX}/etc/influxdb.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/influxd</string>
          <string>-config</string>
          <string>#{HOMEBREW_PREFIX}/etc/influxdb.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/influxdb.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/influxdb.log</string>
        <key>SoftResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>10240</integer>
        </dict>
      </dict>
    </plist>
    EOS
  end

  test do
    (testpath/"config.toml").write shell_output("influxd config")
    inreplace testpath/"config.toml" do |s|
      s.gsub! %r{/.*/.influxdb/data}, "#{testpath}/influxdb/data"
      s.gsub! %r{/.*/.influxdb/meta}, "#{testpath}/influxdb/meta"
      s.gsub! %r{/.*/.influxdb/wal}, "#{testpath}/influxdb/wal"
    end
    if File.readlines(testpath/"config.toml").grep(%r{.influxdb/hh}).any?
      inreplace testpath/"config.toml", %r{/.*/.influxdb/hh}, "#{testpath}/influxdb/hh"
    end

    pid = fork do
      exec "#{bin}/influxd -config #{testpath}/config.toml"
    end
    sleep 5

    begin
      output = shell_output("curl -Is localhost:8086/ping")
      sleep 2
      assert_match /X-Influxdb-Version:/, output
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
