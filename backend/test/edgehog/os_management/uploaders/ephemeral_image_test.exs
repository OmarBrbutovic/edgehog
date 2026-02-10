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

defmodule Edgehog.OSManagement.Uploaders.EphemeralImageTest do
  use ExUnit.Case, async: true

  alias Edgehog.OSManagement.Uploaders.EphemeralImage

  describe "validate/1" do
    test "always returns true" do
      assert EphemeralImage.validate({%Waffle.File{file_name: "ota.bin"}, nil})
    end
  end

  describe "gcs_optional_params/2" do
    test "returns publicRead ACL" do
      params = EphemeralImage.gcs_optional_params(:original, {nil, nil})
      assert Keyword.get(params, :predefinedAcl) == "publicRead"
    end
  end

  describe "storage_dir/2" do
    test "returns correct storage directory" do
      scope = %{tenant_id: "t1", ota_operation_id: "op1"}
      dir = EphemeralImage.storage_dir(:original, {nil, scope})
      assert dir == "uploads/tenants/t1/ephemeral_ota_images/op1"
    end
  end
end
