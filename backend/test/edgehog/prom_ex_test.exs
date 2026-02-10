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

defmodule Edgehog.PromExTest do
  use ExUnit.Case, async: true

  alias Edgehog.PromEx

  describe "plugins/0" do
    test "returns a list of PromEx plugins" do
      plugins = PromEx.plugins()
      assert is_list(plugins)
      assert [_ | _] = plugins
    end
  end

  describe "dashboard_assigns/0" do
    test "returns assigns with datasource_id" do
      assigns = PromEx.dashboard_assigns()
      assert Keyword.get(assigns, :datasource_id) == "prometheus"
      assert Keyword.get(assigns, :default_selected_interval) == "30s"
    end
  end

  describe "dashboards/0" do
    test "returns a list of dashboard configs" do
      dashboards = PromEx.dashboards()
      assert is_list(dashboards)
      assert length(dashboards) == 5
      assert {:prom_ex, "application.json"} in dashboards
    end
  end
end
