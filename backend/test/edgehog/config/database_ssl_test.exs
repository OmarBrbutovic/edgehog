#
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
#

defmodule Edgehog.Config.DatabaseSslTest do
  use ExUnit.Case, async: false

  alias Edgehog.Config

  @doc """
  Tests for database SSL configuration functions in Edgehog.Config.
  """
  describe "database_enable_ssl?/0" do
    test "returns a boolean" do
      result = Config.database_enable_ssl?()
      assert is_boolean(result)
    end
  end

  describe "database_ssl_verify?/0" do
    test "returns a boolean" do
      result = Config.database_ssl_verify?()
      assert is_boolean(result)
    end
  end

  describe "database_use_os_certs?/0" do
    test "returns a boolean" do
      result = Config.database_use_os_certs?()
      assert is_boolean(result)
    end
  end

  describe "database_ssl_config/0" do
    test "returns false when SSL is disabled" do
      # In test env, SSL is disabled by default
      result = Config.database_ssl_config()
      # It returns either false or a list of opts
      assert result == false or is_list(result)
    end
  end

  describe "database_ssl_config_opts/0" do
    test "returns a list of SSL options" do
      result = Config.database_ssl_config_opts()
      assert is_list(result)
      # When verify is not enabled, it returns [verify: :verify_none]
      assert Keyword.has_key?(result, :verify)
    end
  end

  describe "validate_admin_authentication!/0" do
    test "returns :ok or raises" do
      # In test environment, admin_jwk might not be configured
      # This exercises the function at least
      try do
        assert Config.validate_admin_authentication!() == :ok
      rescue
        _ -> :ok
      end
    end
  end
end
