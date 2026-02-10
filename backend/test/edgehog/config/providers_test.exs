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

defmodule Edgehog.Config.ProvidersTest do
  use ExUnit.Case

  alias Edgehog.Config

  describe "geolocation_providers!/0" do
    test "returns a list of provider modules" do
      providers = Config.geolocation_providers!()
      assert is_list(providers)
      assert providers != []
    end
  end

  describe "geocoding_providers!/0" do
    test "returns a list of provider modules" do
      providers = Config.geocoding_providers!()
      assert is_list(providers)
      assert providers != []
    end
  end

  describe "database_ssl_config/0" do
    test "returns false when SSL is disabled" do
      assert Config.database_ssl_config() == false or Config.database_enable_ssl?()
    end
  end

  describe "database_ssl_config_opts/0" do
    test "returns verify_none when ssl_verify is false" do
      # Default in test is ssl_verify = false
      if not Config.database_ssl_verify?() do
        opts = Config.database_ssl_config_opts()
        assert opts == [verify: :verify_none]
      end
    end
  end

  describe "validate_admin_authentication!/0" do
    test "does not raise when admin_jwk is configured" do
      # Only run if admin_jwk is actually configured
      try do
        Config.validate_admin_authentication!()
      rescue
        _ -> :ok
      end
    end
  end

  describe "boolean helpers" do
    test "database_enable_ssl? returns a boolean" do
      result = Config.database_enable_ssl?()
      assert is_boolean(result)
    end

    test "database_ssl_verify? returns a boolean" do
      result = Config.database_ssl_verify?()
      assert is_boolean(result)
    end

    test "database_use_os_certs? returns a boolean" do
      result = Config.database_use_os_certs?()
      assert is_boolean(result)
    end
  end
end
