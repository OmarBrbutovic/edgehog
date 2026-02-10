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

defmodule Edgehog.Assets.Uploaders.SystemModelPictureTest do
  use ExUnit.Case, async: true

  alias Edgehog.Assets.Uploaders.SystemModelPicture

  describe "validate/1" do
    test "accepts .jpg files" do
      assert SystemModelPicture.validate({%Waffle.File{file_name: "photo.jpg"}, nil})
    end

    test "accepts .jpeg files" do
      assert SystemModelPicture.validate({%Waffle.File{file_name: "photo.jpeg"}, nil})
    end

    test "accepts .png files" do
      assert SystemModelPicture.validate({%Waffle.File{file_name: "photo.png"}, nil})
    end

    test "accepts .gif files" do
      assert SystemModelPicture.validate({%Waffle.File{file_name: "photo.gif"}, nil})
    end

    test "accepts .svg files" do
      assert SystemModelPicture.validate({%Waffle.File{file_name: "image.svg"}, nil})
    end

    test "rejects unsupported extensions" do
      refute SystemModelPicture.validate({%Waffle.File{file_name: "file.pdf"}, nil})
    end

    test "is case-insensitive" do
      assert SystemModelPicture.validate({%Waffle.File{file_name: "PHOTO.JPG"}, nil})
    end
  end

  describe "s3_object_headers/2" do
    test "returns content type based on file extension" do
      headers =
        SystemModelPicture.s3_object_headers(
          :original,
          {%Waffle.File{file_name: "photo.png"}, nil}
        )

      assert Keyword.get(headers, :content_type) == "image/png"
    end
  end

  describe "gcs_object_headers/2" do
    test "returns content type for GCS" do
      headers =
        SystemModelPicture.gcs_object_headers(
          :original,
          {%Waffle.File{file_name: "photo.jpg"}, nil}
        )

      assert Keyword.get(headers, :contentType) =~ "image/"
    end
  end

  describe "gcs_optional_params/2" do
    test "returns publicRead ACL" do
      params = SystemModelPicture.gcs_optional_params(:original, {nil, nil})
      assert Keyword.get(params, :predefinedAcl) == "publicRead"
    end
  end

  describe "storage_dir/2" do
    test "returns correct storage directory" do
      scope = %{tenant_id: "tenant-1", handle: "my-model"}
      dir = SystemModelPicture.storage_dir(:original, {nil, scope})
      assert dir == "uploads/tenants/tenant-1/system_models/my-model/picture"
    end
  end
end
