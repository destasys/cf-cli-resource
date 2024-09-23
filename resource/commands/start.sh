
app_name=$(get_option '.app_name')
staging_timeout=$(get_option '.staging_timeout')
startup_timeout=$(get_option '.startup_timeout')

logger::info "Executing #magenta(%s) on app #yellow(%s)" "$command" "$app_name"

cf::target "$org" "$space"
cf::start "$app_name" "$staging_timeout" "$startup_timeout"
