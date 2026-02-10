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

defmodule Edgehog.Campaigns.EnumTypesTest do
  @moduledoc "Tests for enum type modules in campaigns"
  use ExUnit.Case, async: true

  alias Edgehog.Campaigns.CampaignTarget
  alias Edgehog.Campaigns.Outcome
  alias Edgehog.Campaigns.Status

  describe "Outcome" do
    test "graphql_type returns :campaign_outcome" do
      assert :campaign_outcome = Outcome.graphql_type(nil)
    end

    test "match/1 works for valid values" do
      assert {:ok, :success} = Outcome.match(:success)
      assert {:ok, :failure} = Outcome.match(:failure)
    end
  end

  describe "Status" do
    test "graphql_type returns :campaign_status" do
      assert :campaign_status = Status.graphql_type(nil)
    end

    test "match/1 works for valid values" do
      assert {:ok, :idle} = Status.match(:idle)
      assert {:ok, :in_progress} = Status.match(:in_progress)
      assert {:ok, :pausing} = Status.match(:pausing)
      assert {:ok, :paused} = Status.match(:paused)
      assert {:ok, :finished} = Status.match(:finished)
    end
  end

  describe "CampaignTarget.Status" do
    test "graphql_type returns :campaign_target_status" do
      assert :campaign_target_status = CampaignTarget.Status.graphql_type(nil)
    end

    test "match/1 works for valid values" do
      assert {:ok, :idle} = CampaignTarget.Status.match(:idle)
      assert {:ok, :in_progress} = CampaignTarget.Status.match(:in_progress)
      assert {:ok, :failed} = CampaignTarget.Status.match(:failed)
      assert {:ok, :successful} = CampaignTarget.Status.match(:successful)
    end
  end
end
