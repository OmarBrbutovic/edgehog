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

defmodule Edgehog.Containers.Deployment.Validations.NoConflictingCampaignTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.Deployment.Validations.NoConflictingCampaign

  describe "init/1" do
    test "returns ok with valid deployment_start action_type" do
      assert {:ok, :deployment_start} ==
               NoConflictingCampaign.init(action_type: :deployment_start)
    end

    test "returns ok with valid deployment_stop action_type" do
      assert {:ok, :deployment_stop} == NoConflictingCampaign.init(action_type: :deployment_stop)
    end

    test "returns ok with valid deployment_delete action_type" do
      assert {:ok, :deployment_delete} ==
               NoConflictingCampaign.init(action_type: :deployment_delete)
    end

    test "returns ok with valid deployment_upgrade action_type" do
      assert {:ok, :deployment_upgrade} ==
               NoConflictingCampaign.init(action_type: :deployment_upgrade)
    end

    test "returns error with invalid action_type" do
      assert {:error, _msg} = NoConflictingCampaign.init(action_type: :invalid_action)
    end

    test "returns error when action_type is missing" do
      assert {:error, _msg} = NoConflictingCampaign.init([])
    end
  end
end
