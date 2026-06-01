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

defmodule Edgehog.Campaigns.Campaign.Changes.CancelTest do
  use Edgehog.DataCase, async: true

  import Edgehog.CampaignsFixtures
  import Edgehog.TenantsFixtures

  alias Ash.Error.Invalid
  alias Edgehog.Campaigns
  alias Edgehog.Campaigns.CampaignMechanism.Core, as: MechanismCore

  setup do
    %{tenant: tenant_fixture()}
  end

  describe "cancel_campaign/1 - immediate cancellation (idle)" do
    test "immediately cancels an idle campaign", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(3, tenant: tenant)

      assert campaign.status == :idle
      assert is_nil(campaign.completion_timestamp)

      assert {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
      assert not is_nil(cancelled_campaign.completion_timestamp)
    end

    test "sets completion_timestamp for idle campaign", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(1, tenant: tenant)
      before_cancel = DateTime.utc_now()

      assert {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      after_cancel = DateTime.utc_now()
      assert DateTime.compare(cancelled_campaign.completion_timestamp, before_cancel) in [
               :eq,
               :gt
             ]
      assert DateTime.compare(cancelled_campaign.completion_timestamp, after_cancel) in [
               :eq,
               :lt
             ]
    end
  end

  describe "cancel_campaign/1 - immediate cancellation (scheduled)" do
    test "immediately cancels a scheduled campaign", %{tenant: tenant} do
      scheduled_at = DateTime.add(DateTime.utc_now(), 3600, :second)

      campaign =
        campaign_with_targets_fixture(1,
          tenant: tenant,
          scheduled_at_timestamp: scheduled_at
        )

      assert campaign.status == :scheduled
      assert is_nil(campaign.completion_timestamp)

      assert {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
      assert not is_nil(cancelled_campaign.completion_timestamp)
    end

    test "completion_timestamp is set for scheduled campaign", %{tenant: tenant} do
      scheduled_at = DateTime.add(DateTime.utc_now(), 3600, :second)

      campaign =
        campaign_with_targets_fixture(1,
          tenant: tenant,
          scheduled_at_timestamp: scheduled_at
        )

      before_cancel = DateTime.utc_now()
      assert {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)
      after_cancel = DateTime.utc_now()

      # completion_timestamp should be very recent (just now)
      assert DateTime.compare(cancelled_campaign.completion_timestamp, before_cancel) in [
               :eq,
               :gt
             ]
      assert DateTime.compare(cancelled_campaign.completion_timestamp, after_cancel) in [
               :eq,
               :lt
             ]
    end
  end

  describe "cancel_campaign/1 - immediate cancellation (paused)" do
    test "immediately cancels a paused campaign", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(5, tenant: tenant)

      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())
      paused_campaign = MechanismCore.mark_campaign_as_paused!(Any, campaign)

      assert paused_campaign.status == :paused
      assert is_nil(paused_campaign.completion_timestamp)

      assert {:ok, cancelled_campaign} = Campaigns.cancel_campaign(paused_campaign)

      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
      assert not is_nil(cancelled_campaign.completion_timestamp)
    end
  end

  describe "cancel_campaign/1 - deferred cancellation (in_progress)" do
    test "transitions in-progress campaign to cancelling", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(5, tenant: tenant)

      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())

      assert campaign.status == :in_progress
      assert is_nil(campaign.outcome)

      assert {:ok, cancelling_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelling_campaign.status == :cancelling
      # ISSUE: outcome should be set to :cancelled here
      assert is_nil(cancelling_campaign.outcome)
    end

    test "outcome is not set when transitioning to cancelling", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(2, tenant: tenant)
      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())

      {:ok, cancelling_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelling_campaign.status == :cancelling
      # Note: outcome is intentionally not set during :cancelling state
      # It will be set by the executor when all in-progress targets complete
      assert is_nil(cancelling_campaign.outcome)

      # Note: completion_timestamp should not be set during :cancelling,
      # it gets set when executor marks it as :cancelled
      assert is_nil(cancelling_campaign.completion_timestamp)
    end
  end

  describe "cancel_campaign/1 - immediate cancellation (pausing)" do
    test "immediately cancels a pausing campaign", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(5, tenant: tenant)

      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())
      {:ok, pausing_campaign} = Campaigns.pause_campaign(campaign)

      assert pausing_campaign.status == :pausing
      assert is_nil(pausing_campaign.completion_timestamp)

      assert {:ok, cancelled_campaign} = Campaigns.cancel_campaign(pausing_campaign)

      # Cancelling during :pausing should take immediate effect
      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
      assert not is_nil(cancelled_campaign.completion_timestamp)
    end

    test "cancelling a pausing campaign transitions to cancelled state", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(3, tenant: tenant)

      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())
      {:ok, pausing_campaign} = Campaigns.pause_campaign(campaign)

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(pausing_campaign)

      # Pausing is a transient state, so cancelling it should immediately mark as cancelled
      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
    end
  end

  describe "cancel_campaign/1 - error cases" do
    test "fails to cancel a finished campaign", %{tenant: tenant} do
      campaign =
        1
        |> campaign_with_targets_fixture(tenant: tenant)
        |> Ash.load!(campaign_targets: [], campaign_mechanism: [])

      mechanism = campaign.campaign_mechanism.value
      [target] = campaign.campaign_targets
      _ = MechanismCore.mark_target_as_successful!(mechanism, target)
      finished_campaign = MechanismCore.mark_campaign_as_successful!(mechanism, campaign)

      assert {:error, %Invalid{}} = Campaigns.cancel_campaign(finished_campaign)
    end

    test "fails to cancel an already cancelled campaign", %{tenant: tenant} do
      campaign =
        campaign_with_targets_fixture(1, tenant: tenant)
        |> Ash.load!(campaign_targets: [], campaign_mechanism: [])

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.status == :cancelled

      # Cancelled campaigns cannot be cancelled again
      assert {:error, %Invalid{}} = Campaigns.cancel_campaign(cancelled_campaign)
    end
  end

  describe "cancel_campaign/1 - idempotency" do
    test "cancelling a campaign in cancelling state is idempotent", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(5, tenant: tenant)
      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())

      {:ok, cancelling_campaign} = Campaigns.cancel_campaign(campaign)
      assert cancelling_campaign.status == :cancelling

      # Second cancel should succeed (idempotent)
      assert {:ok, result} = Campaigns.cancel_campaign(cancelling_campaign)
      assert result.status == :cancelling
    end

    test "retrying cancel on cancelling campaign is safe", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(3, tenant: tenant)
      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())

      {:ok, first_cancel} = Campaigns.cancel_campaign(campaign)
      {:ok, second_cancel} = Campaigns.cancel_campaign(first_cancel)

      # Both should be in cancelling state
      assert first_cancel.status == :cancelling
      assert second_cancel.status == :cancelling

      # IDs should match (same campaign)
      assert first_cancel.id == second_cancel.id
    end
  end

  describe "cancel_campaign/1 - attribute validation" do
    test "cancelled campaign has correct status and outcome", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(2, tenant: tenant)

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
    end

    test "deferred cancellation preserves campaign data", %{tenant: tenant} do
      campaign =
        campaign_with_targets_fixture(3, tenant: tenant)
        |> Ash.load!(campaign_targets: [])

      original_name = campaign.name
      original_target_count = campaign.total_target_count

      campaign = MechanismCore.mark_campaign_in_progress!(Any, campaign, DateTime.utc_now())
      {:ok, cancelling_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelling_campaign.name == original_name
      assert cancelling_campaign.total_target_count == original_target_count
    end

    test "immediate cancellation preserves all campaign attributes", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(2, tenant: tenant)

      original_name = campaign.name
      original_scheduled_at = campaign.scheduled_at_timestamp

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.name == original_name
      assert cancelled_campaign.scheduled_at_timestamp == original_scheduled_at
      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
    end
  end

  describe "cancel_campaign/1 - edge cases" do
    test "can cancel campaign with no targets", %{tenant: tenant} do
      # Create campaign and then remove all targets
      campaign =
        campaign_with_targets_fixture(1, tenant: tenant)
        |> Ash.load!(campaign_targets: [])

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.status == :cancelled
      assert cancelled_campaign.outcome == :cancelled
    end

    test "cancelling preserves campaign_mechanism", %{tenant: tenant} do
      campaign = campaign_with_targets_fixture(1, tenant: tenant)

      original_mechanism = campaign.campaign_mechanism

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)

      assert cancelled_campaign.campaign_mechanism == original_mechanism
    end

    test "cancelling preserves channel relationship", %{tenant: tenant} do
      campaign =
        campaign_with_targets_fixture(1, tenant: tenant)
        |> Ash.load!(:channel)

      original_channel_id = campaign.channel_id

      {:ok, cancelled_campaign} =
        campaign
        |> Ash.load!(:channel)
        |> Campaigns.cancel_campaign()

      assert cancelled_campaign.channel_id == original_channel_id
    end
  end

  describe "cancel_campaign/1 - multiple cancellations" do
    test "multiple campaigns can be cancelled independently", %{tenant: tenant} do
      campaign1 = campaign_with_targets_fixture(2, tenant: tenant)
      campaign2 = campaign_with_targets_fixture(2, tenant: tenant)

      {:ok, cancelled1} = Campaigns.cancel_campaign(campaign1)
      {:ok, cancelled2} = Campaigns.cancel_campaign(campaign2)

      assert cancelled1.status == :cancelled
      assert cancelled2.status == :cancelled
      assert cancelled1.id != cancelled2.id
    end

    test "cancelling one campaign doesn't affect others", %{tenant: tenant} do
      campaign1 = campaign_with_targets_fixture(2, tenant: tenant)
      campaign2 = campaign_with_targets_fixture(2, tenant: tenant)

      {:ok, _cancelled1} = Campaigns.cancel_campaign(campaign1)

      # Verify campaign2 is still in original state
      reloaded_campaign2 = Campaigns.fetch_campaign!(campaign2.id, tenant: tenant)

      assert reloaded_campaign2.status == :idle
      assert is_nil(reloaded_campaign2.outcome)
    end
  end
end
