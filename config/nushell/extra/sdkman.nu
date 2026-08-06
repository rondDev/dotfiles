$env.JAVA_HOME = ($nu.home-dir | path join ".sdkman/candidates/java/current")
$env.PATH = ($env.PATH | prepend ($env.JAVA_HOME | path join "bin"))

$env.MAVEN_HOME = ($nu.home-dir | path join ".sdkman/candidates/maven/current")
$env.PATH = ($env.PATH | append ($env.MAVEN_HOME | path join "bin"))

def sdk [...args] {
    bash -c $"source ~/.sdkman/bin/sdkman-init.sh && sdk ($args | str join ' ')"
}
