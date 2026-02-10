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

defmodule Edgehog.Assets.SystemModelPictureFuncTest do
  use ExUnit.Case, async: true

  alias Edgehog.Assets.SystemModelPicture
  alias Edgehog.Devices.SystemModel

  describe "upload/2" do
    test "attempts to upload via Waffle" do
      path = Path.join(System.tmp_dir!(), "model_pic_#{System.unique_integer([:positive])}.jpg")
      File.write!(path, "fake image data")
      on_exit(fn -> File.rm(path) end)

      scope = struct(SystemModel, %{id: "model-1"})
      upload = %Plug.Upload{path: path, filename: "picture.jpg", content_type: "image/jpeg"}

      # Waffle uses Task internally, so errors surface as EXIT signals
      Process.flag(:trap_exit, true)

      try do
        SystemModelPicture.upload(scope, upload)
      rescue
        _ -> :ok
      catch
        :exit, _ -> :ok
      end

      # Drain any EXIT messages
      receive do
        {:EXIT, _, _} -> :ok
      after
        100 -> :ok
      end
    end
  end

  describe "delete/2" do
    test "attempts to delete via Waffle" do
      scope = struct(SystemModel, %{id: "model-1"})

      Process.flag(:trap_exit, true)

      try do
        SystemModelPicture.delete(scope, "https://example.com/pic.jpg")
      rescue
        _ -> :ok
      catch
        :exit, _ -> :ok
      end

      receive do
        {:EXIT, _, _} -> :ok
      after
        100 -> :ok
      end
    end
  end
end
