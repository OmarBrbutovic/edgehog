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

defmodule Edgehog.BaseImages.Uploaders.BaseImageTest do
  use ExUnit.Case, async: true

  alias Edgehog.BaseImages.Uploaders.BaseImage

  describe "validate/1" do
    test "always returns true" do
      assert BaseImage.validate({%Waffle.File{file_name: "firmware.bin"}, nil})
      assert BaseImage.validate({%Waffle.File{file_name: "anything.xyz"}, nil})
    end
  end

  describe "gcs_optional_params/2" do
    test "returns publicRead ACL" do
      params = BaseImage.gcs_optional_params(:original, {nil, nil})
      assert Keyword.get(params, :predefinedAcl) == "publicRead"
    end
  end

  describe "storage_dir/2" do
    test "returns correct storage directory" do
      scope = %{tenant_id: "t1", base_image_collection_id: "bic1"}
      dir = BaseImage.storage_dir(:original, {nil, scope})
      assert dir == "uploads/tenants/t1/base_image_collections/bic1/base_images"
    end
  end

  describe "filename/2" do
    test "returns base image version as filename" do
      scope = %{base_image_version: "1.2.3"}
      assert "1.2.3" = BaseImage.filename(:original, {nil, scope})
    end
  end
end
