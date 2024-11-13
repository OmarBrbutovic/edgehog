#
# This file is part of Edgehog.
#
# Copyright 2024 SECO Mind Srl
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

defmodule Edgehog.Devices.Device.ManualActions.SendCreateVolume do
  @moduledoc false
  use Ash.Resource.ManualUpdate

  alias Edgehog.Astarte.Device.CreateVolumeRequest.RequestData

  @send_create_volume_request_behaviour Application.compile_env(
                                          :edgehog,
                                          :astarte_creater_volume_request_module,
                                          Edgehog.Astarte.Device.CreateVolumeRequest
                                        )

  @impl Ash.Resource.ManualUpdate
  def update(changeset, _opts, _context) do
    device = changeset.data

    with {:ok, volume} <- Ash.Changeset.fetch_argument(changeset, :volume),
         {:ok, volume} <- Ash.load(volume, :options_encoding),
         {:ok, device} <- Ash.load(device, :appengine_client) do
      data = %RequestData{
        id: volume.id,
        driver: volume.driver,
        options: volume.options_encoding
      }

      with :ok <-
             @send_create_volume_request_behaviour.send_create_volume_request(
               device.appengine_client,
               device.device_id,
               data
             ) do
        {:ok, device}
      end
    end
  end
end