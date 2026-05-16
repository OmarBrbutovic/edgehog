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

defmodule Edgehog.Campaigns.Campaign.Workers.ScheduleCampaignTest do
  use Edgehog.DataCase, async: true

  use Oban.Testing, repo: Edgehog.Repo

  import Edgehog.CampaignsFixtures
  import Edgehog.TenantsFixtures

  alias Edgehog.Campaigns
  alias Edgehog.Campaigns.ExecutorRegistry
  alias Edgehog.Campaigns.Campaign.Workers.ScheduleCampaign

  describe "perform/1" do
    test "starts campaign executor when job is performed with valid campaign id" do
      tenant = tenant_fixture()

      campaign = campaign_fixture(tenant: tenant)

      job_args = %{"id" => campaign.id, "tenant" => tenant.tenant_id}

      assert {:ok, _campaign} = perform_job(ScheduleCampaign, job_args)
    end

    test "returns error when campaign does not exist" do
      tenant = tenant_fixture()
      non_existent_id = Ecto.UUID.generate()

      job_args = %{"id" => non_existent_id, "tenant" => tenant.tenant_id}

      assert {:error, %Ash.Error.Invalid{}} = perform_job(ScheduleCampaign, job_args)
    end

    test "returns error when tenant does not have campaign access" do
      tenant1 = tenant_fixture()
      tenant2 = tenant_fixture()

      campaign = campaign_fixture(tenant: tenant1)

      # Try to execute job with different tenant
      job_args = %{"id" => campaign.id, "tenant" => tenant2.tenant_id}

      assert {:error, %Ash.Error.Invalid{}} = perform_job(ScheduleCampaign, job_args)
    end

    test "does not start an executor for a cancelled scheduled campaign" do
      tenant = tenant_fixture()
      scheduled_at = DateTime.add(DateTime.utc_now(), 3600, :second)

      campaign =
        campaign_with_targets_fixture(1,
          tenant: tenant,
          scheduled_at_timestamp: scheduled_at
        )

      assert campaign.status == :scheduled

      {:ok, cancelled_campaign} = Campaigns.cancel_campaign(campaign)
      assert cancelled_campaign.status == :cancelled

      job_args = %{"id" => campaign.id, "tenant" => tenant.tenant_id}

      assert {:ok, _campaign} = perform_job(ScheduleCampaign, job_args)

      assert [] ==
               Registry.lookup(ExecutorRegistry, {
                 tenant.tenant_id,
                 campaign.id,
                 campaign.campaign_mechanism.type
               })
    end
  end
end
