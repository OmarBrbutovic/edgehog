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

defmodule Edgehog.Validations.MoreEdgeTest do
  use ExUnit.Case, async: true

  alias Edgehog.Tenants.Tenant
  alias Edgehog.Validations.PEMPublicKey
  alias Edgehog.Validations.Version, as: VersionValidation
  alias Edgehog.Validations.VersionRequirement

  @doc """
  Tests for uncovered init/validate error branches in validation modules.
  """
  describe "PEMPublicKey" do
    test "init returns error for non-atom attribute" do
      assert {:error, "attribute must be an atom"} = PEMPublicKey.init(attribute: "string_attr")
    end

    test "validate returns :ok when attribute not in changeset" do
      changeset = %Ash.Changeset{
        data: struct(Tenant),
        attributes: %{},
        arguments: %{},
        action_type: :update
      }

      assert :ok = PEMPublicKey.validate(changeset, [attribute: :public_key], %{})
    end
  end

  describe "Version" do
    test "init returns error for non-atom attribute" do
      assert {:error, "attribute must be an atom"} = VersionValidation.init(attribute: "string")
    end

    test "validate returns :ok when attribute not in changeset" do
      changeset = %Ash.Changeset{
        data: struct(Tenant),
        attributes: %{},
        arguments: %{},
        action_type: :update
      }

      assert :ok = VersionValidation.validate(changeset, [attribute: :version], %{})
    end
  end

  describe "VersionRequirement" do
    test "init returns error for non-atom attribute" do
      assert {:error, "attribute must be an atom"} = VersionRequirement.init(attribute: 123)
    end

    test "validate returns :ok when attribute not in changeset" do
      changeset = %Ash.Changeset{
        data: struct(Tenant),
        attributes: %{},
        arguments: %{},
        action_type: :update
      }

      assert :ok = VersionRequirement.validate(changeset, [attribute: :requirement], %{})
    end
  end
end
