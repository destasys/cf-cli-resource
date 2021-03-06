
buildpack=$(get_option '.buildpack')
path=$(get_option '.path')
position=$(get_option '.position')
enabled=$(get_option '.enabled')

logger::info "Executing $(logger::highlight "$command"): $buildpack"

args=("$buildpack" $path "$position") # don't quote $path so we can support globbing
[ "$enabled" == "true" ]  && args+=(--enable)
[ "$enabled" == "false" ] && args+=(--disable)

cf create-buildpack "${args[@]}"
