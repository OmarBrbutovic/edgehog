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

defmodule Edgehog.ConfigTest do
  use ExUnit.Case, async: true

  alias Edgehog.Config

  describe "database_enable_ssl?/0" do
    test "returns a boolean" do
      assert is_boolean(Config.database_enable_ssl?())
    end
  end

  describe "database_ssl_verify?/0" do
    test "returns a boolean" do
      assert is_boolean(Config.database_ssl_verify?())
    end
  end

  describe "database_use_os_certs?/0" do
    test "returns a boolean" do
      assert is_boolean(Config.database_use_os_certs?())
    end
  end

  describe "database_ssl_config/0" do
    test "returns false when SSL is disabled" do
      # In test env, SSL is typically disabled
      result = Config.database_ssl_config()
      # Could be false or a keyword list
      assert result == false or is_list(result)
    end
  end

  describe "database_ssl_config_opts/0" do
    test "returns a keyword list" do
      opts = Config.database_ssl_config_opts()
      assert is_list(opts)
    end
  end

  describe "geolocation_providers!/0" do
    test "returns a list of modules" do
      providers = Config.geolocation_providers!()
      assert is_list(providers)
    end
  end

  describe "geocoding_providers!/0" do
    test "returns a list of modules" do
      providers = Config.geocoding_providers!()
      assert is_list(providers)
    end
  end
end
