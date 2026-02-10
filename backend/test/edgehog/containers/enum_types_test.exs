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

defmodule Edgehog.Containers.EnumTypesTest do
  @moduledoc "Tests for enum type modules in containers"
  use ExUnit.Case, async: true

  alias Edgehog.Containers.Deployment.Types.DeploymentState

  describe "DeploymentState" do
    test "graphql_type returns :application_deployment_state" do
      assert :application_deployment_state = DeploymentState.graphql_type(nil)
    end

    test "match/1 works for valid values" do
      assert {:ok, :pending} = DeploymentState.match(:pending)
      assert {:ok, :sent} = DeploymentState.match(:sent)
      assert {:ok, :started} = DeploymentState.match(:started)
      assert {:ok, :stopped} = DeploymentState.match(:stopped)
    end
  end
end
