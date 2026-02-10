# This file is part of Edgehog.
#
# Copyright 2026 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

defmodule Edgehog.Config.SslCertTest do
  # Not async because we modify Skogsra cached config values
  use ExUnit.Case, async: false

  alias Edgehog.Config

  describe "database_ssl_config_opts/0 with ssl_verify enabled" do
    setup do
      # Save current cached values by reading them
      original_verify = Config.database_ssl_verify?()
      original_use_os_certs = Config.database_use_os_certs?()
      original_cacertfile = System.get_env("DATABASE_SSL_CACERTFILE")

      on_exit(fn ->
        # Restore original Skogsra cached values
        Config.put_database_ssl_verify(original_verify)
        Config.put_database_use_os_certs(original_use_os_certs)

        if original_cacertfile do
          System.put_env("DATABASE_SSL_CACERTFILE", original_cacertfile)
        else
          System.delete_env("DATABASE_SSL_CACERTFILE")
        end
      end)

      :ok
    end

    test "returns verify_peer opts with cacertfile when DATABASE_SSL_CACERTFILE is set" do
      Config.put_database_ssl_verify(true)
      Config.put_database_use_os_certs(false)
      System.put_env("DATABASE_SSL_CACERTFILE", "/path/to/cert.pem")

      opts = Config.database_ssl_config_opts()

      assert {:verify, :verify_peer} in opts
      assert {:cacertfile, "/path/to/cert.pem"} in opts
    end

    test "returns verify_peer opts with os certs when DATABASE_USE_OS_CERTS is true" do
      Config.put_database_ssl_verify(true)
      Config.put_database_use_os_certs(true)
      System.delete_env("DATABASE_SSL_CACERTFILE")

      opts = Config.database_ssl_config_opts()

      assert {:verify, :verify_peer} in opts
      assert {:cacerts, _certs} = List.keyfind(opts, :cacerts, 0)
    end

    test "raises when ssl_verify is true but no certs configured" do
      Config.put_database_ssl_verify(true)
      Config.put_database_use_os_certs(false)
      System.delete_env("DATABASE_SSL_CACERTFILE")

      assert_raise RuntimeError, ~r/invalid database SSL configuration/, fn ->
        Config.database_ssl_config_opts()
      end
    end
  end

  describe "database_ssl_config/0" do
    setup do
      original_enable = Config.database_enable_ssl?()
      original_verify = Config.database_ssl_verify?()

      on_exit(fn ->
        Config.put_database_enable_ssl(original_enable)
        Config.put_database_ssl_verify(original_verify)
      end)

      :ok
    end

    test "returns ssl opts when ssl is enabled" do
      Config.put_database_enable_ssl(true)
      Config.put_database_ssl_verify(false)

      result = Config.database_ssl_config()
      assert is_list(result)
      assert {:verify, :verify_none} in result
    end

    test "returns false when ssl is disabled" do
      Config.put_database_enable_ssl(false)

      assert Config.database_ssl_config() == false
    end
  end
end
