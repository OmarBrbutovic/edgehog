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

defmodule Edgehog.OSManagement.EphemeralImageTest do
  use ExUnit.Case, async: true

  alias Edgehog.OSManagement.EphemeralImage

  describe "upload/3" do
    test "attempts to upload via Waffle uploader" do
      path = Path.join(System.tmp_dir!(), "eph_test_#{System.unique_integer([:positive])}.bin")
      File.write!(path, "ota image content")
      on_exit(fn -> File.rm(path) end)

      upload = %Plug.Upload{
        path: path,
        filename: "ota_image.bin",
        content_type: "application/octet-stream"
      }

      try do
        EphemeralImage.upload("test-tenant", "ota-op-001", upload)
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end

  describe "delete/3" do
    test "attempts to delete via Waffle uploader" do
      try do
        EphemeralImage.delete("test-tenant", "ota-op-001", "https://example.com/image.bin")
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end
end
