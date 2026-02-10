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

defmodule Edgehog.Campaigns.CampaignMechanismTypeTest do
  use ExUnit.Case, async: true

  alias Edgehog.Campaigns.CampaignMechanism

  @doc """
  Tests for the CampaignMechanism union type and its graphql_type/1 and graphql_unnested_unions/1.
  """
  describe "graphql_type/1" do
    test "returns :campaign_mechanism" do
      assert :campaign_mechanism = CampaignMechanism.graphql_type(%{})
    end
  end

  describe "graphql_unnested_unions/1" do
    test "returns all mechanism types" do
      result = CampaignMechanism.graphql_unnested_unions(%{})
      assert :deployment_deploy in result
      assert :deployment_start in result
      assert :deployment_stop in result
      assert :deployment_delete in result
      assert :deployment_upgrade in result
      assert :firmware_upgrade in result
      assert length(result) == 6
    end
  end
end
