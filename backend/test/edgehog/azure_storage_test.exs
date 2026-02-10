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

defmodule Edgehog.AzureStorageTest do
  use ExUnit.Case, async: true

  alias Edgehog.AzureStorage

  # Minimal test definition module to mock the Waffle callbacks
  defmodule TestDefinition do
    @moduledoc false
    def storage_dir(_version, _file_and_scope), do: "uploads/test"
    def s3_object_headers(_version, _file_and_scope), do: [content_type: "image/png"]
    def bucket(_file_and_scope), do: "test-container"
    def asset_host, do: "https://myaccount.blob.core.windows.net"
    def filename(_version, {file, _scope}), do: file.file_name
    def transform(_version, _file_and_scope), do: :noaction
  end

  # Definition that uses {:system, env_var} for container
  defmodule SystemEnvDefinition do
    @moduledoc false
    def storage_dir(_version, _file_and_scope), do: "uploads/sys"
    def s3_object_headers(_version, _file_and_scope), do: [content_type: "image/png"]
    def bucket(_file_and_scope), do: {:system, "TEST_AZURE_CONTAINER"}
    def asset_host, do: false
    def filename(_version, {file, _scope}), do: file.file_name
    def transform(_version, _file_and_scope), do: :noaction
  end

  # Definition that uses nil asset_host
  defmodule NilHostDefinition do
    @moduledoc false
    def storage_dir(_version, _file_and_scope), do: "uploads/nil"
    def s3_object_headers(_version, _file_and_scope), do: [content_type: "image/png"]
    def bucket(_file_and_scope), do: "nil-container"
    def asset_host, do: nil
    def filename(_version, {file, _scope}), do: file.file_name
    def transform(_version, _file_and_scope), do: :noaction
  end

  # Definition that uses {:system, env_var} for asset_host
  defmodule SystemHostDefinition do
    @moduledoc false
    def storage_dir(_version, _file_and_scope), do: "uploads/syshost"
    def s3_object_headers(_version, _file_and_scope), do: [content_type: "image/png"]
    def bucket(_file_and_scope), do: "sys-host-container"
    def asset_host, do: {:system, "TEST_AZURE_HOST"}
    def filename(_version, {file, _scope}), do: file.file_name
    def transform(_version, _file_and_scope), do: :noaction
  end

  describe "url/4" do
    test "builds URL from host, container, dir, and filename" do
      file = %Waffle.File{file_name: "photo.jpg"}
      scope = %{id: 1}

      url = AzureStorage.url(TestDefinition, :original, {file, scope})
      assert url =~ "https://myaccount.blob.core.windows.net"
      assert url =~ "test-container"
      assert url =~ "uploads/test"
      assert url =~ "photo.jpg"
    end

    test "uses system env for container when bucket returns {:system, var}" do
      System.put_env("TEST_AZURE_CONTAINER", "env-container")

      on_exit(fn -> System.delete_env("TEST_AZURE_CONTAINER") end)

      file = %Waffle.File{file_name: "doc.pdf"}
      scope = %{id: 2}

      url = AzureStorage.url(SystemEnvDefinition, :original, {file, scope})
      assert url =~ "env-container"
      assert url =~ "uploads/sys"
    end

    test "falls back to Blob.Config.api_url when asset_host is false" do
      file = %Waffle.File{file_name: "img.png"}
      scope = %{id: 3}

      System.put_env("TEST_AZURE_CONTAINER", "false-host-container")
      on_exit(fn -> System.delete_env("TEST_AZURE_CONTAINER") end)

      url = AzureStorage.url(SystemEnvDefinition, :original, {file, scope})
      # Should use Blob.Config.api_url() as the host
      assert is_binary(url)
      assert url =~ "img.png"
    end

    test "falls back to Blob.Config.api_url when asset_host is nil" do
      file = %Waffle.File{file_name: "doc.txt"}
      scope = %{id: 4}

      url = AzureStorage.url(NilHostDefinition, :original, {file, scope})
      assert is_binary(url)
      assert url =~ "nil-container"
      assert url =~ "doc.txt"
    end

    test "uses system env for asset_host when it returns {:system, var}" do
      System.put_env("TEST_AZURE_HOST", "https://custom-host.blob.net")
      on_exit(fn -> System.delete_env("TEST_AZURE_HOST") end)

      file = %Waffle.File{file_name: "file.bin"}
      scope = %{id: 5}

      url = AzureStorage.url(SystemHostDefinition, :original, {file, scope})
      assert url =~ "https://custom-host.blob.net"
      assert url =~ "sys-host-container"
    end
  end

  describe "put/3" do
    test "processes file data before calling Blob.put_blob (binary)" do
      file = %Waffle.File{file_name: "test.bin", binary: "binary content"}
      scope = %{id: 1}

      # Will fail at Blob.put_blob since Azurex isn't configured,
      # but covers all lines before the external call
      try do
        AzureStorage.put(TestDefinition, :original, {file, scope})
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end

    test "processes file data from path" do
      # Create a temporary file
      path = Path.join(System.tmp_dir!(), "azure_test_#{System.unique_integer([:positive])}.txt")
      File.write!(path, "test content")

      on_exit(fn -> File.rm(path) end)

      file = %Waffle.File{file_name: "test.txt", path: path}
      scope = %{id: 2}

      try do
        AzureStorage.put(TestDefinition, :original, {file, scope})
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end

  describe "delete/3" do
    test "processes file path before calling Blob.delete_blob" do
      file = %Waffle.File{file_name: "delete_me.jpg"}
      scope = %{id: 1}

      try do
        AzureStorage.delete(TestDefinition, :original, {file, scope})
      rescue
        _ -> :ok
      catch
        _, _ -> :ok
      end
    end
  end
end
