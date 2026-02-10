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

defmodule Edgehog.Containers.Container.ValidationsTest do
  use ExUnit.Case, async: true

  alias Edgehog.Containers.Container.Validations.BindsFormat
  alias Edgehog.Containers.Container.Validations.CpuPeriodQuotaConsistency
  alias Edgehog.Containers.Container.Validations.VolumeTargetUniqueness

  describe "BindsFormat" do
    test "init returns ok" do
      assert {:ok, []} == BindsFormat.init([])
    end

    test "validates correct bind format (host:container)" do
      changeset = %Ash.Changeset{data: %{binds: ["/host/path:/container/path"]}}
      assert :ok == BindsFormat.validate(changeset, [], %{})
    end

    test "validates bind with options (host:container:options)" do
      changeset = %Ash.Changeset{data: %{binds: ["/host:/container:ro"]}}
      assert :ok == BindsFormat.validate(changeset, [], %{})
    end

    test "validates multiple correct binds" do
      changeset = %Ash.Changeset{
        data: %{binds: ["/src:/dst", "/data:/app/data:rw"]}
      }

      assert :ok == BindsFormat.validate(changeset, [], %{})
    end

    test "returns error for invalid bind format" do
      changeset = %Ash.Changeset{data: %{binds: ["invalid"]}}
      assert {:error, _msg} = BindsFormat.validate(changeset, [], %{})
    end

    test "returns error for empty source" do
      changeset = %Ash.Changeset{data: %{binds: [":/container"]}}
      assert {:error, _msg} = BindsFormat.validate(changeset, [], %{})
    end

    test "returns error for empty target" do
      changeset = %Ash.Changeset{data: %{binds: ["/host:"]}}
      assert {:error, _msg} = BindsFormat.validate(changeset, [], %{})
    end

    test "returns ok for empty binds list" do
      changeset = %Ash.Changeset{data: %{binds: []}}
      assert :ok == BindsFormat.validate(changeset, [], %{})
    end

    test "returns ok for nil binds" do
      changeset = %Ash.Changeset{data: %{binds: nil}}
      assert :ok == BindsFormat.validate(changeset, [], %{})
    end

    test "returns error for non-binary bind" do
      changeset = %Ash.Changeset{data: %{binds: [123]}}
      assert {:error, _msg} = BindsFormat.validate(changeset, [], %{})
    end

    test "describe returns message" do
      result = BindsFormat.describe([])
      assert is_list(result)
      assert Keyword.has_key?(result, :message)
    end
  end

  describe "CpuPeriodQuotaConsistency" do
    test "init returns ok" do
      assert {:ok, []} == CpuPeriodQuotaConsistency.init([])
    end

    test "validates when both nil" do
      changeset = %Ash.Changeset{
        data: %{cpu_period: nil, cpu_quota: nil},
        arguments: %{}
      }

      assert :ok == CpuPeriodQuotaConsistency.validate(changeset, [], %{})
    end

    test "validates when both set" do
      changeset = %Ash.Changeset{
        data: %{cpu_period: 100_000, cpu_quota: 50_000},
        arguments: %{}
      }

      assert :ok == CpuPeriodQuotaConsistency.validate(changeset, [], %{})
    end

    test "returns error when only cpu_period is set" do
      changeset = %Ash.Changeset{
        data: %{cpu_period: 100_000, cpu_quota: nil},
        arguments: %{}
      }

      assert {:error, _msg} = CpuPeriodQuotaConsistency.validate(changeset, [], %{})
    end

    test "returns error when only cpu_quota is set" do
      changeset = %Ash.Changeset{
        data: %{cpu_period: nil, cpu_quota: 50_000},
        arguments: %{}
      }

      assert {:error, _msg} = CpuPeriodQuotaConsistency.validate(changeset, [], %{})
    end

    test "describe returns message" do
      result = CpuPeriodQuotaConsistency.describe([])
      assert is_list(result)
    end
  end

  describe "VolumeTargetUniqueness" do
    test "init returns ok" do
      assert {:ok, []} == VolumeTargetUniqueness.init([])
    end

    test "validates unique volume targets" do
      changeset = %Ash.Changeset{
        arguments: %{volumes: [%{target: "/data"}, %{target: "/logs"}]}
      }

      assert :ok == VolumeTargetUniqueness.validate(changeset, [], %{})
    end

    test "returns error for duplicate volume targets" do
      changeset = %Ash.Changeset{
        arguments: %{volumes: [%{target: "/data"}, %{target: "/data"}]}
      }

      assert {:error, _msg} = VolumeTargetUniqueness.validate(changeset, [], %{})
    end

    test "returns ok when no volumes argument" do
      changeset = %Ash.Changeset{arguments: %{}}
      assert :ok == VolumeTargetUniqueness.validate(changeset, [], %{})
    end

    test "describe returns message" do
      result = VolumeTargetUniqueness.describe([])
      assert is_list(result)
    end
  end
end
