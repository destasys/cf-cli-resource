#!/usr/bin/env shellspec

set -euo pipefail

Describe 'config'
  Include resource/lib/error-codes.sh

  It can 'error if params not set'
    put_without_params() {
      local config=$(
        %text
        #|source:
      )
      put "$config"
    }
    When call put_without_params
    The status should eq $E_PARAMS_NOT_SET
    The error should end with "invalid payload (missing params)"
  End

  It can 'error if api not set'
    put_without_source_api() {
      local config=$(
        %text
        #|source:
        #|params:
        #|  SOME_PARAM: some_value
      )
      put "$config"
    }
    When call put_without_source_api
    The status should eq $E_API_NOT_SET
    The error should end with "invalid payload (missing api)"
  End

  It can 'error if neither username or client_id are set'
    put_without_username_or_client_id() {
      local config=$(
        %text
        #|source:
        #|  api: https://api.run.example.com
        #|params:
        #|  SOME_PARAM: some_value
      )
      put "$config"
    }
    When call put_without_username_or_client_id
    The status should eq $E_NEITHER_USERNAME_OR_CLIENT_ID_SET
    The error should end with "invalid payload (must specify username or client_id)"
  End

  It can 'error if both username and client_id are set'
    put_with_username_and_client_id() {
      local config=$(
        %text
        #|source:
        #|  api: https://api.run.example.com
        #|  username: some_user
        #|  client_id: some_client_id
        #|params:
        #|  SOME_PARAM: some_value
      )
      put "$config"
    }
    When call put_with_username_and_client_id
    The status should eq $E_BOTH_USERNAME_AND_CLIENT_ID_SET
    The error should end with "invalid payload (must specify only username or client_id)"
  End

  It can 'error if password not set'
    put_without_password() {
      local config=$(
        %text
        #|source:
        #|  api: https://api.run.example.com
        #|  username: some_user
        #|params:
        #|  SOME_PARAM: some_value
      )
      put "$config"
    }
    When call put_without_password
    The status should eq $E_PASSWORD_NOT_SET
    The error should end with "invalid payload (missing password)"
  End

  It can 'error if client_secret not set'
    put_without_client_secret() {
      local config=$(
        %text
        #|source:
        #|  api: https://api.run.example.com
        #|  client_id: some_client_id
        #|params:
        #|  SOME_PARAM: some_value
      )
      put "$config"
    }
    When call put_without_client_secret
    The status should eq $E_CLIENT_SECRET_NOT_SET
    The error should end with "invalid payload (missing client_secret)"
  End

  Context 'using mock cf'
    Mock cf
      case "$1" in
      version)
        echo "cf version 0.0.0+fake.0"
        ;;
      *)
        exit 0
        ;;
      esac
    End
    Mock cf7
      cf "$@"
    End
    Mock cf8
      cf "$@"
    End

    It can 'error if command not set'
      put_without_command() {
        local config=$(
          %text
          #|source:
          #|  api: https://api.run.example.com
          #|  username: some_user
          #|  password: some_password
          #|params:
          #|  SOME_PARAM: some_value
        )
        put "$config"
      }
      When call put_without_command
      The status should eq $E_COMMAND_NOT_SET
      The error should end with "invalid payload (missing command)"
    End

    It can 'error if command_file not found'
      put_with_invalid_command_file() {
        local config=$(
          %text
          #|source:
          #|  api: https://api.run.example.com
          #|  username: some_user
          #|  password: some_password
          #|params:
          #|  command_file: does_not_exist.yml
        )
        put "$config"
      }
      When call put_with_invalid_command_file
      The status should eq $E_COMMAND_FILE_NOT_FOUND
      The error should end with "invalid payload (can not find command_file: does_not_exist.yml)"
    End

    It can 'error if zero-downtime-push manifest not found'
      put_with_invalid_manifest() {
        local config=$(
          %text
          #|source:
          #|  api: https://api.run.example.com
          #|  username: some_user
          #|  password: some_password
          #|params:
          #|  command: zero-downtime-push
          #|  manifest: does_not_exist.yml
        )
        put "$config"
      }
      When call put_with_invalid_manifest
      The status should eq $E_MANIFEST_FILE_NOT_FOUND
      The error should end with "invalid payload (manifest is not a file: does_not_exist.yml)"
    End

    It can 'error if unknown command set'
      put_with_unknown_command() {
        local config=$(
          %text
          #|source:
          #|  api: https://api.run.example.com
          #|  username: some_user
          #|  password: some_password
          #|params:
          #|  command: does-not-exist
        )
        put "$config"
      }
      When call put_with_unknown_command
      The status should eq $E_UNKNOWN_COMMAND
      The error should end with "invalid payload (unknown command: does-not-exist)"
    End
  End
End
